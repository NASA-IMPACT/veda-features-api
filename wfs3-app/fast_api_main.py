import logging
import os
import sys
import json

from fastapi import FastAPI, Request, Response, APIRouter, status
from fastapi.routing import APIRoute
from fastapi.responses import JSONResponse
from opentelemetry import trace, metrics
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from starlette_cramjam.middleware import CompressionMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.middleware.cors import CORSMiddleware
from tipg.db import close_db_connection, connect_to_db, register_collection_catalog
from tipg.factory import Endpoints as FeaturesEndpoints
from tipg.settings import PostgresSettings, APISettings, DatabaseSettings
from tipg.middleware import CatalogUpdateMiddleware
from typing import Callable

logger = logging.getLogger(__name__)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(formatter)
logger.setLevel(logging.INFO)
logger.addHandler(handler)

try:
    # staging/production ECS setup
    db_config = json.loads(os.environ.get("DB_CONFIG"))
except TypeError:
    # local docker
    db_config = {
        "username": os.environ.get("POSTGRES_USER"),
        "password": os.environ.get("POSTGRES_PASS"),
        "host": os.environ.get("POSTGRES_HOST"),
        "port": os.environ.get("POSTGRES_PORT"),
        "dbname": os.environ.get("POSTGRES_DBNAME")
    }

tracer = trace.get_tracer(__name__)
meter = metrics.get_meter(__name__)
refresh_counter = meter.create_counter(
    "refresh.counter", unit="1", description="counts the number of releases so we can graph b/c CW metrics are trash"
)


class LoggerRouteHandler(APIRoute):

    def get_route_handler(self) -> Callable:
        original_route_handler = super().get_route_handler()

        async def route_handler(request: Request) -> Response:
            ctx = {
                "path": request.url.path,
                "route": self.path,
                "method": request.method,
            }
            logger.info(f"[ REQUEST SCOPE ]: {request.scope}")
            logger.info(f"[ REQUEST HEADERS ]: {request.headers}")
            with tracer.start_as_current_span("handle_request") as route_handler_span:
                return await original_route_handler(request)

        return route_handler


# TODO: this is hack to fix the issue where our `X-Forwarded-Proto` header
# does not seem to be reaching the FastAPI code and b/c `starlette` package
# isn't setting the scheme correctly, still need to figure this out
# we are already doing everything that `uvicorn` is telling us to do
# prior art:
# https://www.uvicorn.org/settings/#http
# https://github.com/developmentseed/titiler/discussions/345
# https://github.com/encode/starlette/issues/604
# https://github.com/encode/starlette/issues/692
class FixUrlMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        request.scope["scheme"] = os.environ.get("FAST_API_SCHEME", "http")
        response = await call_next(request)
        return response


app = FastAPI(
    title="EIS Fire boundaries",
    openapi_url="/api",
    docs_url="/api.html",
)

postgresql_settings = PostgresSettings(**{
    "postgres_user": db_config["username"],
    "postgres_pass": db_config["password"],
    "postgres_host": db_config["host"],
    "postgres_port": db_config["port"],
    "postgres_dbname": db_config["dbname"]
})
api_settings = APISettings()
db_settings = DatabaseSettings()

endpoints = FeaturesEndpoints(router=APIRouter(route_class=LoggerRouteHandler))
app.include_router(endpoints.router, tags=["OGC Features"])
app.add_middleware(CompressionMiddleware)
app.add_middleware(FixUrlMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)
if api_settings.catalog_ttl:
    app.add_middleware(
        CatalogUpdateMiddleware,
        ttl=api_settings.catalog_ttl,
        schemas=db_settings.schemas,
        tables=db_settings.tables,
        exclude_tables=db_settings.exclude_tables,
        exclude_table_schemas=db_settings.exclude_table_schemas,
        functions=db_settings.functions,
        exclude_functions=db_settings.exclude_functions,
        exclude_function_schemas=db_settings.exclude_function_schemas,
        spatial=db_settings.only_spatial_tables,
    )


@app.on_event("startup")
async def startup_event() -> None:
    """Connect to database on startup."""
    with tracer.start_as_current_span("startup_event"):
        await connect_to_db(app, settings=postgresql_settings)
        await register_collection_catalog(app)


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Close database connection."""
    await close_db_connection(app)


@app.get(
    "/healthz",
    description="Health Check.",
    summary="Health Check.",
    operation_id="healthCheck",
    tags=["Health Check"],
)
async def ping():
    return JSONResponse(status_code=200, content={"ping": "pong"})


@app.get("/refresh")
async def refresh(request: Request):
    """Return parsed catalog data for testing."""
    with tracer.start_as_current_span("refresh"):
        refresh_counter.add(1, {"refresh": "count"})
        await connect_to_db(app, settings=postgresql_settings)
        await register_collection_catalog(app)
        return JSONResponse(status_code=200, content={"status": "refreshed"})

FastAPIInstrumentor.instrument_app(app, excluded_urls="/conformance,/healthz")

import logging
import os
import sys
import json

from fastapi import FastAPI, Request, Response, APIRouter
from fastapi.routing import APIRoute
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from starlette_cramjam.middleware import CompressionMiddleware
from tipg.db import close_db_connection, connect_to_db, register_collection_catalog
from tipg.factory import Endpoints as FeaturesEndpoints
from tipg.settings import PostgresSettings
from typing import Callable

logger = logging.getLogger(__name__)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(formatter)
logger.setLevel(logging.INFO)
logger.addHandler(handler)

# :TECHDEBT: why do we need two `json.loads`?
db_config = json.loads(json.loads(os.environ.get("DB_CONFIG")))

tracer = trace.get_tracer(__name__)


class LoggerRouteHandler(APIRoute):

    def get_route_handler(self) -> Callable:
        original_route_handler = super().get_route_handler()

        async def route_handler(request: Request) -> Response:
            ctx = {
                "path": request.url.path,
                "route": self.path,
                "method": request.method,
            }
            with tracer.start_as_current_span("handle_request") as route_handler_span:
                route_handler_span.set_attribute("request.context.path", ctx["path"])
                route_handler_span.set_attribute("request.context.route", ctx["route"])
                route_handler_span.set_attribute("request.context.method", ctx["method"])
                return await original_route_handler(request)

        return route_handler


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

endpoints = FeaturesEndpoints(router=APIRouter(route_class=LoggerRouteHandler))
app.include_router(endpoints.router, tags=["OGC Features"])
app.add_middleware(CompressionMiddleware)

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

FastAPIInstrumentor.instrument_app(app, excluded_urls="/conformance")
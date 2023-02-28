import logging
import os
import sys
import json

from aws_xray_sdk.core import xray_recorder, patch_all
from fastapi import FastAPI, Request, Response, APIRouter
from fastapi.routing import APIRoute
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

logging.getLogger('aws_xray_sdk').setLevel(logging.DEBUG)
plugins = ('ECSPlugin',)
# https://github.com/aws/aws-xray-sdk-python/issues/201
xray_recorder.configure(
    service=f"veda-wfs3-{os.environ.get('ENVIRONMENT', 'dev')}",
    streaming_threshold=0,
    plugins=plugins,
    context_missing='LOG_ERROR'
)
patch_all()


class LoggerRouteHandler(APIRoute):

    def get_route_handler(self) -> Callable:
        original_route_handler = super().get_route_handler()

        async def route_handler(request: Request) -> Response:
            # add fastapi context to logs
            ctx = {
                "path": request.url.path,
                "route": self.path,
                "method": request.method,
            }
            # TODO: metrics and structured logging setups here
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
    await connect_to_db(app, settings=postgresql_settings)
    await register_collection_catalog(app)


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Close database connection."""
    await close_db_connection(app)

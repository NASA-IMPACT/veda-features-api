import asyncio
import logging
import os

from aws_lambda_powertools import Logger, Metrics, Tracer
from aws_lambda_powertools.metrics import MetricUnit  # noqa: F401
from aws_xray_sdk.core import xray_recorder
from fastapi import FastAPI, Request, Response, APIRouter
from fastapi.routing import APIRoute
from mangum import Mangum
from starlette_cramjam.middleware import CompressionMiddleware
from starlette.responses import JSONResponse
from tipg.db import close_db_connection, connect_to_db, register_collection_catalog
from tipg.factory import Endpoints as FeaturesEndpoints
from typing import Callable

logging.getLogger("mangum.lifespan").setLevel(logging.ERROR)
logging.getLogger("mangum.http").setLevel(logging.ERROR)

# https://github.com/aws/aws-xray-sdk-python/issues/201
xray_recorder.configure(
    streaming_threshold=1
)

logger: Logger = Logger(service="veda-wfs3", namespace="veda-wfs3")
metrics: Metrics = Metrics(service="veda-wfs3", namespace="veda-wfs3")
tracer: Tracer = Tracer()


class LoggerRouteHandler(APIRoute):
    """Extension of base APIRoute to add context to log statements, as well as record usage metricss"""

    def get_route_handler(self) -> Callable:
        """Overide route handler method to add logs, metrics, tracing"""
        original_route_handler = super().get_route_handler()

        async def route_handler(request: Request) -> Response:
            # Add fastapi context to logs
            ctx = {
                "path": request.url.path,
                "route": self.path,
                "method": request.method,
            }
            logger.append_keys(fastapi=ctx)
            logger.info("Received request")
            metrics.add_metric(
                name="/".join(
                    str(request.url).split("/")[:2]
                ),  # enough detail to capture search IDs, but not individual tile coords
                unit=MetricUnit.Count,
                value=1,
            )
            tracer.put_annotation(key="path", value=request.url.path)
            tracer.capture_method(original_route_handler)(request)
            return await original_route_handler(request)

        return route_handler



app = FastAPI(
    title="EIS Fire boundaries",
    openapi_url="/api",
    docs_url="/api.html",
)

handler = Mangum(app, lifespan="auto")
# Add tracing
handler.__name__ = "handler"  # tracer requires __name__ to be set
handler = tracer.capture_lambda_handler(handler)
# Add logging
handler = logger.inject_lambda_context(handler, clear_state=True)
# Add metrics last to properly flush metrics.
handler = metrics.log_metrics(handler, capture_cold_start_metric=True)

# Register endpoints.
endpoints = FeaturesEndpoints(router=APIRouter(route_class=LoggerRouteHandler))
app.include_router(endpoints.router, tags=["OGC Features"])
app.add_middleware(CompressionMiddleware)

@app.on_event("startup")
async def startup_event() -> None:
    """Connect to database on startup."""
    await connect_to_db(app)
    await register_collection_catalog(app)


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Close database connection."""
    await close_db_connection(app)


# If the correlation header is used in the UI, we can analyze traces that originate from a given user or client
@app.middleware("http")
async def add_correlation_id(request: Request, call_next):
    """Add correlation ids to all requests and subsequent logs/traces"""
    # Get correlation id from X-Correlation-Id header if provided
    corr_id = request.headers.get("x-correlation-id")
    if not corr_id:
        try:
            # If empty, use request id from aws context
            corr_id = request.scope["aws.context"].aws_request_id
        except KeyError:
            # If empty, use uuid
            corr_id = "local"
    # Add correlation id to logs
    logger.set_correlation_id(corr_id)
    # Add correlation id to traces
    tracer.put_annotation(key="correlation_id", value=corr_id)

    response = await tracer.capture_method(call_next)(request)
    # Return correlation header in response
    response.headers["X-Correlation-Id"] = corr_id
    logger.info("Request completed")
    return response


@app.exception_handler(Exception)
async def validation_exception_handler(request, err):
    """Handle exceptions that aren't caught elsewhere"""
    metrics.add_metric(name="UnhandledExceptions", unit=MetricUnit.Count, value=1)
    logger.exception("Unhandled exception")
    return JSONResponse(status_code=500, content={"detail": "Internal Server Error"})

if "AWS_EXECUTION_ENV" in os.environ:
    loop = asyncio.get_event_loop()
    loop.run_until_complete(app.router.startup())

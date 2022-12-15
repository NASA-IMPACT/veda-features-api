
import os
import asyncio

from tifeatures.db import close_db_connection, connect_to_db, register_table_catalog
from tifeatures.factory import Endpoints as FeaturesEndpoints
from fastapi import FastAPI
from starlette_cramjam.middleware import CompressionMiddleware

from mangum import Mangum

app = FastAPI(
    title="EIS Fire boundaries",
    openapi_url="/api",
    docs_url="/api.html",
)

# Register endpoints.
endpoints = FeaturesEndpoints()
app.include_router(endpoints.router, tags=["OGC Features"])

# By default the VectorTilerFactory will only create tiles/ and tilejson.json endpoints
# mvt_endpoints = VectorTilerFactory()
# app.include_router(mvt_endpoints.router)

app.add_middleware(CompressionMiddleware)


@app.on_event("startup")
async def startup_event() -> None:
    """Connect to database on startup."""
    await connect_to_db(app)
    # TiMVT and TiFeatures share the same `Table_catalog` format
    # see https://github.com/developmentseed/timvt/pull/83
    await register_table_catalog(app)


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Close database connection."""
    await close_db_connection(app)


handler = Mangum(app, lifespan="off")

if "AWS_EXECUTION_ENV" in os.environ:
    loop = asyncio.get_event_loop()
    loop.run_until_complete(app.router.startup())

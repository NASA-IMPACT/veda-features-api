"""STACK Configs."""

from typing import Optional

import pydantic


class APISettings(pydantic.BaseSettings):
    """Application settings"""

    name: str = "tifeatures-timvt"
    stage: str = "staging"

    owner: Optional[str]
    client: Optional[str]
    project: Optional[str]

    timeout: int = 30
    memory: int = 3008

    # The maximum of concurrent executions you want to reserve for the function.
    # Default: - No specific limit - account limit.
    max_concurrent: Optional[int]

    class Config:
        """model config"""

        env_file = "stack/.env"
        env_prefix = "CDK_API_"


class DBSettings(pydantic.BaseSettings):
    """Application settings"""

    dbname: str = "veda"
    user: str = "veda"

    class Config:
        """model config"""

        env_file = "stack/.env"
        env_prefix = "CDK_DB_"

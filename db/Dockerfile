FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.9

# WORKDIR /tmp

RUN pip install boto3 requests "urllib3<2" psycopg["binary"] -t "${LAMBDA_TASK_ROOT}"

COPY ./handler.py ${LAMBDA_TASK_ROOT}

# https://stackoverflow.com/a/61746719
# Turns out, asyncio is part of python
# RUN rm -rf /asset/asyncio*

CMD ["handler.handler"]

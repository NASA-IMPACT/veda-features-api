ARG PYTHON_VERSION=3.10

FROM ghcr.io/vincentsarago/uvicorn-gunicorn:${PYTHON_VERSION}

WORKDIR /tmp

COPY stack/app/requirements.txt requirements.txt
RUN pip install -r requirements.txt

# ENV MODULE_NAME app.handler
# ENV VARIABLE_NAME app
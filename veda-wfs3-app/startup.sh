################################################################
# since we cannot ssh into a ECS container :booo:
# we use the following scripts to validate and test :yeaaahhhh:
################################################################
#python -m http.server 8080
#python pyserver.py
#################################################################
# FAST API
#################################################################
opentelemetry-bootstrap --action=install && opentelemetry-instrument python /opt/bitnami/python/bin/uvicorn fast_api_main:app --host 0.0.0.0 --port 8080

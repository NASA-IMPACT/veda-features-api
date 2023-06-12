################################################################
# FAST API
#################################################################
# opentelemetry-bootstrap --action=install \
#   && opentelemetry-instrument python /opt/bitnami/python/bin/uvicorn \
#   fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080

python /opt/bitnami/python/bin/uvicorn \
fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080

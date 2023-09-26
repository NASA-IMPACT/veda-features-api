################################################################
# FAST API
#################################################################
if [ "$ENVIRONMENT" == "prod" ]; then
    /opt/bitnami/python/bin/uvicorn fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080
elif [ "$ENVIRONMENT" == "dev" ]; then
    /opt/bitnami/python/bin/uvicorn fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080
elif [ "$ENVIRONMENT" == "west2-staging" ]; then
    opentelemetry-bootstrap --action=install \
      && opentelemetry-instrument python /opt/bitnami/python/bin/uvicorn \
      fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080
else
    echo "[ ENVIRONMENT UNKNOWN ]: value='$ENVIRONMENT'...exiting"
fi


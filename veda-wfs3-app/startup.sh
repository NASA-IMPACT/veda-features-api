################################################################
# FAST API
#################################################################
echo "######## DB SETUP ########" | tee /dev/stderr
echo $DB_CONFIG | jq -r "to_entries|map(\"export \(.key)=\(.value|tostring)\")|.[]" > .env
chmod 777 .env && source .env
psql -d "postgresql://${username}:${password}@${host}/${dbname}" -c "CREATE EXTENSION IF NOT EXISTS postgis;"
psqloutput=$(psql -d "postgresql://${username}:${password}@${host}/${dbname}" -c "SELECT extname FROM pg_extension WHERE extname = 'postgis';")
echo $psqloutput | tee /dev/stderr
echo "######## END DB SETUP ########" | tee /dev/stderr

if [ "$ENVIRONMENT" == "prod" ]; then
  echo "[ ENVIRONMENT PROD WITH ROOT PATH ]"
  /opt/bitnami/python/bin/uvicorn fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080 --root-path=/api/features
elif [ "$ENVIRONMENT" == "dev" ]; then
  /opt/bitnami/python/bin/uvicorn fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080
elif [ "$ENVIRONMENT" == "west2-staging" ]; then
  opentelemetry-bootstrap --action=install \
    && opentelemetry-instrument python /opt/bitnami/python/bin/uvicorn \
    fast_api_main:app --proxy-headers --forwarded-allow-ips="*"  --host 0.0.0.0 --port 8080
else
  echo "[ ENVIRONMENT UNKNOWN ]: value='$ENVIRONMENT'...exiting"
  exit 1
fi


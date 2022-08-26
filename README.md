### EIS Fires

#### Deploying

To deploy, just run `cdk synth`, `cdk bootstrap` and `cdk deploy`.

After deploying, an stdout with the url to the endpoint and the AWS secret ARN will be provided. The AWS secret ARN is useful to be able to use ogr2ogr to publish data to the database. Either use the command line or the AWS console to get those values to connect to the database or use ogr2ogr.

#### Adding data to the database

To add append to a table:

`ogr2ogr -f "PostgreSQL" PG:"host=HOST dbname=DBNAME user=USER password=PASSWORD" "LargeFires_2012-2020.gpkg" -nln fire_boundaries2 -append`

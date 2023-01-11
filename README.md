# VEDA Features API

Hosting and serving collections of vector data features for VEDA.

## Implementation

* Storage: PostGIS
* API with query support: [OGC API Features](https://ogcapi.ogc.org/features/) provided by [TiFeatures](https://github.com/developmentseed/tifeatures)
* Possible extension to support server-side rendering of large feature sets: vector tiles API provided by [TiMVT](https://github.com/developmentseed/timvt) (not yet implemented)


## Deploying

To deploy, just run `cdk synth`, `cdk bootstrap` and `cdk deploy`.

After deploying, an stdout with the url to the endpoint and the AWS secret ARN will be provided. The AWS secret ARN is useful to be able to use ogr2ogr to publish data to the database. Either use the command line or the AWS console to get those values to connect to the database or use ogr2ogr.

## Adding data to the database

To add append to a table:

`ogr2ogr -f "PostgreSQL" PG:"host=HOST dbname=DBNAME user=USER password=PASSWORD" "LargeFires_2012-2020.gpkg" -nln fire_boundaries2 -append`

## Docker for local development

To run locally on docker use:

`docker compose up`

## Commiting
We use this action to create tags https://github.com/mathieudutour/github-tag-action

This uses [conventional commit methodology](https://www.conventionalcommits.org/en/v1.0.0/) to create tags using the logic detailed [here](https://github.com/mathieudutour/github-tag-action#bumping)

# License
This project is licensed under **Apache 2**, see the [LICENSE](LICENSE) file for more details.


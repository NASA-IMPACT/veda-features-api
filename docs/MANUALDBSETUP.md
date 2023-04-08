#### Manually Setting up the DB

0. Log into your instance as `postgres`:

`psql postgresql://postgres:<password>@<rds-host>:5432`

1. Create the default DB:

```bash
CREATE DATABASE veda;
```

2. Create the user with the correct privileges:

```bash
CREATE USER veda WITH PASSWORD '<your-password>';
GRANT CONNECT ON DATABASE veda TO veda;
GRANT CREATE ON DATABASE veda TO veda;
GRANT USAGE ON SCHEMA public TO veda;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO veda;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO veda;
```

3. Create `postgis` extension:

```bash
CREATE EXTENSION IF NOT EXISTS postgis;
```

4. Using `ogr2ogr` you can then load flatgeobuff files:

```bash
ogr2ogr -f "PostgreSQL" \
  "PG:host=<rds-hostname> dbname=veda user=postgres password=<password>" \
  -t_srs "EPSG:4326" \
  /tmp/perimeter.fgb \
  -nln eis_2023_perimeter \
  -append \
  -sql "SELECT n_pixels, n_newpixels, farea, fperim, flinelen, duration, pixden, meanFRP, isactive, t_ed as t, fireID as fid from perimeter" \
  -progress
```

#### Dump Existing Site

`pg_dump -Fc -h <rds-host-name> -U postgres -W <password> > /tmp/wfs3.dump`

#### Restore From Dump

`pg_restore --verbose -h <rds-host-name> -p 5432 -U postgres -W -d veda /tmp/wfs3.dump`
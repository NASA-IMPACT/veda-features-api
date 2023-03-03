import os
import sys
import logging
import json
import psycopg2
import time

from http.server import HTTPServer, CGIHTTPRequestHandler

logger = logging.getLogger(__name__)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(formatter)
logger.setLevel(logging.INFO)
logger.addHandler(handler)

# :TECHDEBT: why do we need two `json.loads`?
db_config = json.loads(json.loads(os.environ.get("DB_CONFIG")))

os.chdir('.')
server_object = HTTPServer(server_address=('', 8080), RequestHandlerClass=CGIHTTPRequestHandler)

conn = psycopg2.connect(**{
    "user": db_config["username"],
    "password": db_config["password"],
    "host": db_config["host"],
    "database": db_config["dbname"]
})

while True:
    time.sleep(60)
    cur = conn.cursor()
    cur.execute('SELECT version()')
    db_version = cur.fetchone()
    logger.info(f"################### {db_version} ########################")

server_object.serve_forever()
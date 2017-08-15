#!/bin/bash
until $(nc -z $HOST 5432); do
  echo "Waiting for PostgreSQL to come up"
  sleep 1
done
/entrypoint.sh openerp-server &
until $(curl --output /dev/null --silent --head --fail http://localhost:8069/web); do
  echo "Waiting for Odoo to come up"
  sleep 5
done
echo -e "db_host = $HOST\ndb_user = $USER\ndb_password = $PASSWORD" >> /etc/odoo/server.cfg
source /opt/nh/venv/bin/activate
cd /opt/odoo/db_init
inv demo.slam -d liveobs -c /etc/odoo/server.cfg
inv test.test_enable_all_modules -d liveobs
export PGUSER=${USER}
export PGPASSWORD=${PASSWORD}
mkdir -p /opt/odoo/dumps
pg_dump -h ${HOST} -d liveobs > /tmp/liveobs.sql
ls -talh /opt/odoo
mv /tmp/liveobs.sql /opt/odoo/dumps

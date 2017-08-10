#!/bin/bash
/entrypoint.sh openerp-server &
echo "sleeping for 20 seconds..."
sleep 20
echo -e "db_host = $HOST\ndb_user = $USER\ndb_password = $PASSWORD" >> /etc/odoo/server.cfg
source /opt/nh/venv/bin/activate
cd /opt/odoo/db_init
inv demo.slam -d liveobs -c /etc/odoo/server.cfg

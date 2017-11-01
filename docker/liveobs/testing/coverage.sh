#!/bin/bash
echo -e "db_host = $HOST\ndb_user = $USER\ndb_password = $PASSWORD" >> /etc/odoo/server.cfg
/entrypoint.sh coverage -d db -u nh_odoo_fixes --test-enable --stop-after-init
/entrypoint.sh collect-coverage
s3cmd put /opt/nh/unit_test_coverage.xml "s3://liveobs-build/artifacts/odoo/coverage/${VERSION}/unit_test_coverage.xml"

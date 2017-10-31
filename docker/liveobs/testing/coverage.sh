#!/bin/bash
echo -e "db_host = $HOST\ndb_user = $USER\ndb_password = $PASSWORD" >> /etc/odoo/server.cfg
/entrypoint.sh coverage -d db -u nh_eobs_slam --test-enable --stop-after-init
/entrypoint.sh collect-coverage
s3cmd put /opt/nh/unit_test_coverage.xml "s3://liveobs-build/artifacts/odoo/coverage/${GO_PIPELINE_COUNTER}/unit_test_coverage.xml"

#!/bin/bash
echo -e "db_host = $HOST\ndb_user = $USER\ndb_password = $PASSWORD" >> /etc/odoo/server.cfg

# Start the odoo server
/entrypoint.sh coverage -d db -u nh_odoo_fixes &
echo $! > /opt/nh/odoo.pid
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Odoo server: $status"
  exit $status
fi

while /bin/true; do
  ps aux | grep odoo | grep -q -v grep
  ODOO_STATUS=$?
  # if odoo has stopped see if file is written locally
  if [ $ODOO_STATUS -ne 0 ]; then
    if [ -e "/opt/nh/opt/nh/unit_test_coverage.xml" ]; then
      COVERAGE_UPLOADED=$(s3cmd ls "s3://liveobs-build/artifacts/odoo/coverage/${VERSION}/integration_test_coverage.xml" | wc -l)
      if [ $COVERAGE_UPLOADED -gt 0 ]; then
        exit 0
      else
        s3cmd put /opt/nh/unit_test_coverage.xml "s3://liveobs-build/artifacts/odoo/coverage/${VERSION}/integration_test_coverage.xml"
      fi
    fi
  fi
  sleep 60
done

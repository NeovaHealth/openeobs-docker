FROM 298801546701.dkr.ecr.eu-west-1.amazonaws.com/odoo

USER root
# Get /etc/odoo/server.cfg to use addons path with addons
ADD createdb.sh /opt/odoo/createdb.sh
RUN chown odoo /opt/odoo/createdb.sh
RUN chmod +x /opt/odoo/createdb.sh

RUN set -x; \
    sed -i 's/\/opt\/odoo\/addons/\/opt\/odoo\/addons,\/opt\/odoo\/liveobs_addons/g' /etc/odoo/server.cfg

USER odoo
# Copy files into place
COPY ./liveobs_addons /opt/odoo/liveobs_addons
COPY ./helper_scripts/db_init /opt/odoo/db_init

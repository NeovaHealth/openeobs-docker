FROM 298801546701.dkr.ecr.eu-west-1.amazonaws.com/odoo:8.0-old

ARG VERSION
ENV VERSION=$VERSION

USER root
# Get /etc/odoo/server.cfg to use addons path with addons
RUN chown -R odoo /opt/odoo

RUN set -x; \
    sed -i 's/\/opt\/odoo\/addons/\/opt\/odoo\/addons,\/opt\/odoo\/liveobs_addons/g' /etc/odoo/server.cfg

USER odoo
# Copy files into place
COPY ./liveobs_addons /opt/odoo/liveobs_addons
COPY ./helper_scripts/db_init /opt/odoo/db_init

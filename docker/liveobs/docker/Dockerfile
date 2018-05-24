FROM 298801546701.dkr.ecr.eu-west-1.amazonaws.com/odoo:8.0

ARG VERSION
ENV VERSION=$VERSION

USER root

COPY ./server.cfg /etc/odoo/server.cfg
RUN chown odoo /etc/odoo/server.cfg

# Oodo/Liveobs verion of wsgi.py for vhost X-FORWARDED-HOST fix
COPY ./wsgi.py /opt/nh/venv/lib/python2.7/site-packages/werkzeug/wsgi.py

USER odoo
# Copy files into place
COPY ./liveobs_addons /opt/odoo/liveobs_addons
COPY ./helper_scripts/db_init /opt/odoo/db_init

from invoke import task
from util import util


@task
def default(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create DEFAULT live data base
    """
    util.createdb(db, server, user, password, False, verbose, install_modules=['nh_clinical_default'])


@task
def cwp(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='etc/odoo/odoo.cfg', verbose=False):
    """
    Create CWP (Cheshire and Wirral) demo database
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_cwp', 'nh_eobs_adt_gui', 'nh_eobs_backup'])

from invoke import task
from util import util

@task
def upgrade(db, server='http://localhost:8069', user='admin', password='admin', verbose=False, module='c4h_ecommerce'):
    """Update using ERPPeek"""
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    client.upgrade(module)

@task
def install(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create C4h data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['c4h_ecommerce'])


from invoke import task
from util import util

@task
def upgrade(db, server='http://localhost:8069', user='admin', password='admin', verbose=False, module='nh_base'):
    """Update using ERPPeek"""
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    client.upgrade(module)

@task
def neova(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create Neova data base
    """
    # odoo 7 : util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, version='7', install_modules=['nh_base'])
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_base'])

@task
def create(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False, base_module='nh_base'):
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=[base_module])

from invoke import task
from util import util


@task
def default(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create DEFAULT live data base
    """
    util.createdb(db, server, user, password, False, verbose, install_modules=['nh_clinical_default'])


@task
def btuh(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create BTUH live data base
    """
    util.createdb(db, server, user, password, False, verbose, install_modules=['nh_clinical_btuh'])


@task
def ldh(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create LDH live data base
    """
    util.createdb(db, server, user, password, False, verbose, install_modules=['nh_clinical_ldh'])

    
@task
def lister(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create LDH live data base
    """
    util.createdb(db, server, user, password, False, verbose, install_modules=['nh_clinical_lister'])

    
@task
def lth(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create LDH live data base
    """
    util.createdb(db, server, user, password, False, verbose, install_modules=['nh_clinical_lth'])

@task
def slam(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='etc/odoo/odoo.cfg', verbose=False):
    """
    Create SLAM (South London & Maudsley Hospital) demo database
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_slam', 'nh_eobs_adt_gui', 'nh_eobs_backup'])

@task
def cwp(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='etc/odoo/odoo.cfg', verbose=False):
    """
    Create CWP (Cheshire and Wirral) demo database
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_cwp', 'nh_eobs_adt_gui', 'nh_eobs_backup'])

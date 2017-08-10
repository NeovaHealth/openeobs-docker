# -*- coding: utf-8 -*-
from invoke import task
from util import util


help = {'db': "Data Base"}


@task
def upgrade(db, server='http://localhost:8069', user='admin', password='admin', verbose=False, module='nh_base'):
    """Update using ERPPeek"""
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    client.upgrade(module)


@task
def default(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create DEFAULT demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_mobile', 'nh_eobs_analysis'])


@task
def demo(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create a demo demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_mobile', 'nh_eobs_demo', 'nh_eobs_analysis', 'nh_eobs_adt_gui'])

@task
def dev(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create DEVELOPMENT default e-obs data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_dev'])


@task
def btuh(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create BTUH (Basildon and Thurrock University Hospitals) demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_btuh', 'nh_eobs_demo'])


@task
def ldh(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create LDH (Luton & Dunstable Hospital) demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_clinical_ldh', 'nh_eobs_demo'])


@task
def lister(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create Lister demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_lister', 'nh_eobs_demo'])


@task
def lth(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create LTH (Leeds Teaching Hospitals) demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_lth', 'nh_eobs_demo'])


@task
def ldh(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='/etc/odoo/odoo.cfg', verbose=False):
    """
    Create LDH (Luton & Dunstable Hospital) demo data base
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_ldh', 'nh_eobs_demo'])


@task
def slam(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='etc/odoo/odoo.cfg', verbose=False):
    """
    Create SLAM (South London & Maudsley Hospital) demo database
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_slam', 'nh_eobs_demo', 'nh_eobs_adt_gui', 'nh_eobs_analysis'])


@task
def cwp(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='etc/odoo/odoo.cfg', verbose=False):
    """
    Create CWP (Cheshire and Wirral) demo database
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs_cwp', 'nh_eobs_demo', 'nh_eobs_adt_gui', 'nh_eobs_analysis'])


@task
def internal(db, server='http://localhost:8069', user='admin', password='admin', demo=False, cfg_odoo='etc/odoo/odoo.cfg', verbose=False):
    """
    Install NH internal code.
    """
    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_base', 'nh_issue_merge'])

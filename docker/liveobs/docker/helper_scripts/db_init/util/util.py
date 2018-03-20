import erppeek
import openerp.service
from invoke import task


def drop_and_create_database(db_name, cfg='/etc/odoo/odoo.cfg', demo=False, lang='en_GB', version='8'):
    openerp.tools.config.parse_config(['-c', cfg])
    config = openerp.tools.config
    print "Version: %s" % version
    if version != '8':
      db = openerp.service.web_services.db()
    else:
      db = openerp.service.db
      openerp.api.Environment._local.environments = openerp.api.Environments()
    db.exp_drop(db_name)
    print "Dropped db - %s" % db_name
    db.exp_create_database(db_name, demo, lang)


def get_erppeek_client(server, db=None, user=None, password=None, verbose=False):
    try:
        client = erppeek.Client(server, db=db, user=user, password=password, verbose=verbose)
    except:
        print "Could not connect to server %s with parameters db: %s, user: %s, password: %s " % (server, db, user, password)
        print "Exiting..."
        exit(1)
    return client


def createdb(db, server='http://localhost:8069', user='admin', password='admin', demo=False, verbose=False, 
             install_modules=['nh_clinical_default'], demo_modules=[], cfg_odoo='/etc/odoo/odoo.cfg', version='8'):
    
    drop_and_create_database(db, cfg=cfg_odoo, lang='en_GB', demo=demo, version=version)
    
    client = get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)

    install_modules and client.install(*install_modules)
    if demo:
        ids = client.search('ir.module.module', [['name', 'like', 'nh_%%']])
        client.write('ir.module.module', ids, {'demo': True})
    return True

@task
def test_enable_module(db, server='http://localhost:8069', user='admin', password='admin', module_to_enable=''):
    """
    Enable testing for only one module
    :param db: Name of database
    :param server: Server address
    :param user: User to use when enabling / disabling testing
    :param password: Password for aforementioned user
    :param module_to_enable: Name of the module to enable
    :return:True
    """
    # Get the client
    client = get_erppeek_client(server, db=db, user=user, password=password, verbose=True)

    # Using the supplied module name get Neova Health modules and sort those to be enabled / disabled
    module_ids = client.search('ir.module.module', [['name', 'ilike', 'nh_%'], ['name', '!=', 'test_inherit']])
    modules = client.read('ir.module.module', module_ids, ['name'])
    modules_not_to_test = [mod['id'] for mod in modules if mod['name'] != module_to_enable]
    module_to_test = [mod['id'] for mod in modules if mod['name'] == module_to_enable]

    # Write to the database
    client.write('ir.module.module', modules_not_to_test, {'demo': False})
    client.write('ir.module.module', module_to_test, {'demo': True})
    return True

@task
def test_enable_all_modules(db, server='http://localhost:8069', user='admin', password='admin'):
    """
    Enable testing for all Neova Health / BJSS modules.

    :param db: Name of database
    :param server: Server address
    :param user: User to use when enabling / disabling testing
    :param password: Password for aforementioned user
    :return:True
    """
    # Get the client.
    client = get_erppeek_client(server, db=db, user=user, password=password, verbose=True)

    # Using the supplied module name get modules and sort those to be
    # enabled / disabled.
    modules_to_test = client.search(
        'ir.module.module',
        [
            ['author', '=', 'Neova Health'],
            ['author', '=', 'BJSS'],
            ['name', '!=', 'test_inherit']
        ]
    )

    # Write to the database.
    client.write('ir.module.module', modules_to_test, {'demo': True})
    return True

@task
def install_module(db, server='http://localhost:8069', user='admin', password='admin', module_to_install=''):
    """ Install a module into database
    :param db: Name of the database
    :param server: Server address
    :param user: User to install ass
    :param password: Password for aforementioned user
    :param module_to_install: Module to install
    :return: True
    """
    # get client
    client = get_erppeek_client(server, db=db, user=user, password=password, verbose=True)

    #install module
    client.install(module_to_install)
    return True

@task
def uninstall_module(db, server='http://localhost:8069', user='admin', password='admin', module_to_uninstall=''):
    """ Uninstall a module from database
    :param db: Name of the database
    :param server: Server address
    :param user: User to install ass
    :param password: Password for aforementioned user
    :param module_to_uninstall: Module to uninstall
    :return: True
    """
    # get client
    client = get_erppeek_client(server, db=db, user=user, password=password, verbose=True)

    #uninstall module
    client.uninstall(module_to_uninstall)
    return True
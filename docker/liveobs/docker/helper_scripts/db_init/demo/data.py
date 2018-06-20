from invoke import task
from datetime import datetime as dt, timedelta as td
from openerp.tools import DEFAULT_SERVER_DATETIME_FORMAT as dtf
import erppeek
from util import util


@task
def place_patients(db, server='http://localhost:8069', user='admin', password='admin', verbose=False,
            bed_codes=[]):
    """
    Place patient in every named bed 
    """
    bed_codes = [bc.strip() for bc in "".join(bed_codes).split(",")]
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    imd_ids = client.search('ir.model.data', [['model', '=', 'nh.clinical.pos'], ['name', 'ilike', '%hospital%']])
    if not imd_ids:
        print "POS with xmlid='nhc_def_conf_pos_hospital' is not found. Exiting..."
        exit(1)     
    print "bed_codes:  %s" % bed_codes
    pos = client.read('ir.model.data', imd_ids, ['res_id'])
    pos_id = pos[0]['res_id']
    bed_location_ids = client.search('nh.clinical.location', [['code', 'in', bed_codes], ['pos_id','=',pos_id]])
    if not bed_location_ids:
        print "No beds found with code in %s for pos_id: %s" % (bed_codes, pos_id)
        exit(0)
    for bed_id in bed_location_ids:
        try:
            client.execute('nh.clinical.api.demo', 'register_admit_place', bed_id, {}, {}, True)
        except Exception as e:
            print "Could not place to bed_id: %s. Reason: %s" % (bed_id, e)

@task
def admit_patients(db, server='http://localhost:8069', user='admin', password='admin', verbose=False,
            ward_codes=[], patient_count=1):
    """
    Admit patient_count patients in every named ward 
    """
    ward_codes = [wc.strip() for wc in "".join(ward_codes).split(",")]
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    imd_ids = client.search('ir.model.data', [['model','=','nh.clinical.pos'], ['name', 'ilike', '%hospital%']])
    if not imd_ids:
        print "POS with xmlid='nhc_def_conf_pos_hospital' is not found. Exiting..."
        exit(1) 
    print "ward_codes:  %s" % ward_codes
    pos = client.read('ir.model.data', imd_ids, ['res_id'])
    pos_id = pos[0]['res_id']
    ward_location_ids = client.search('nh.clinical.location', [['code','in',ward_codes], ['pos_id','=',pos_id]])
    
    for ward_id in ward_location_ids:
        count = patient_count
        while count:
            try:
                client.execute('nh.clinical.api.demo', 'register_admission', ward_id, {}, {}, True)
            except Exception as e:
                print "Could not admit to ward_id: %s. Reason: %s" % (ward_id, e)    
            count -= 1
                
@task
def uat_default_env(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create UAT environment: 18 placed patients per ward and 4 waiting patients
    """
    bed_codes = ['A01,A02,A03,A04,A05,A06,A07,A08,A09,A10,A11,A12,A13,A14,A15,A16,A17,A18,' \
                'B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B12,B13,B14,B15,B16,B17,B18,' \
                'C01,C02,C03,C04,C05,C06,C07,C08,C09,C10,C11,C12,C13,C14,C15,C16,C17,C18,' \
                'D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11,D12,D13,D14,D15,D16,D17,D18']
    ward_codes = ['A,B,C,D']
    place_patients(db, server, user, password, verbose, bed_codes)
    admit_patients(db, server, user, password, verbose, ward_codes, patient_count=4)
    news_simulation(db, server, user, password, verbose)


@task
def load_data(db, server='http://localhost:8069', user='admin', password='admin', verbose=False, wards=10, beds=10, patients=10, begin_date=False):
    """
    Add eObs data
    """
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    data = {
        'wards': wards,
        'beds': beds,
        'patients': patients,
        'begin_date': begin_date
    }
    try:
        client.execute('nh.clinical.api.demo', 'build_eobs_uat_env', data, {})
    except Exception as e:
        print "Error trying to add data into %s. Reason: %s" % (db, e)

@task
def ews(db, server='http://localhost:8069', user='admin', password='admin', verbose=False,
            bed_codes=[], ews_count=3):
    """
    Submit-Completes ews obs for bed_codes if bed_codes passed where patient is placed, beds without patients skipped
    If bed_codes not passed all beds of POS nhc_def_conf_pos_hospital are affected
    Loops for ews-count times
    """
    bed_codes = [bc.strip() for bc in "".join(bed_codes).split(",")]
    bed_codes = [bc for bc in bed_codes if bc]
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    client.execute('nh.clinical.api.demo', 'submit_ews_observations', bed_codes, ews_count)

@task
def news_simulation(db, server='http://localhost:8069', user='admin', password='admin', verbose=False, days=1):
    """
    Generates a news observation simulation for every patient in the db during the amount of time specified.
    """
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    begin_date = (dt.now()-td(days=days)).strftime(dtf)
    client.execute('nh.clinical.api.demo', 'generate_news_simulation', begin_date)

@task
def load_test(db, server='http://localhost:8069', user='admin', password='admin', demo=False, load_cfg=None, cfg_odoo='/etc/odoo/odoo.cfg', return_file=None, verbose=False):
    """
    Generates a hospital for load testing.
    """
    if not load_cfg:
        raise "Error! A env_config is needed."

    if not return_file:
        return_file = 'user_logins.json'

    util.createdb(db, cfg_odoo=cfg_odoo, server=server, user=user, password=password, demo=demo, verbose=verbose, install_modules=['nh_eobs', 'nh_eobs_mobile'])
    client = util.get_erppeek_client(server, db=db, user=user, password=password, verbose=verbose)
    client.execute('nh.clinical.api.demo', 'demo_loader', load_cfg, return_file)
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
def uat_lister_env(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create Lister UAT environment: 13 placed patients per ward and 4 waiting patients
    """
    bed_codes = ['6BN01,6BN02,6BN03,6BN04,6BN05,6BN06,6BN07,6BN08,6BN09,6BN10,6BN11,6BN12,6BN13,'
                 '6BS16,6BS17,6BS18,6BS19,6BS20,6BS21,6BS22,6BS23,6BS24,6BSDC01,6BSDC02,6BSDC03,6BSDC04']
    ward_codes = ['06BN,06BS']
    place_patients(db, server, user, password, verbose, bed_codes)
    admit_patients(db, server, user, password, verbose, ward_codes, patient_count=4)
    news_simulation(db, server, user, password, verbose)


@task
def uat_lth_env(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create LTH (Leeds Teaching Hospitals) UAT environment: 30 placed patients and 4 waiting patients
    """
    bed_codes = ['J83B1,J83B2,J83B3,J83B4,J83B5,J83B6,J83B7,J83B8,J83B9,J83B10,J83B11,J83B12,J83B13,'
                 'J83B16,J83B17,J83B18,J83B19,J83B20,J83B21,J83B22,J83B23,J83B24,J83B25,J83B26,J83B27,J83B28,'
                 'J83B29,J83B30']
    ward_codes = ['J83']
    place_patients(db, server, user, password, verbose, bed_codes)
    admit_patients(db, server, user, password, verbose, ward_codes, patient_count=4)
    news_simulation(db, server, user, password, verbose)


@task
def uat_btuh_env(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create BTUH (Basildon & Thurrock University Hospitals) UAT environment: 30 placed patients in Elizabeth Fry,
    25 placed patients in Florence Nightingale and 4 waiting patients
    """
    bed_codes = ['EFMB1,EFMB2,EFMB3,EFMB4,EFMB5,EFMB6,EFMB7,EFMB8,EFMB9,EFMB10,EFMB11,EFMB12,EFMB13,EFMB14,EFMB15,'
                 'EFMB16,EFMB17,EFMB18,EFMB19,EFMB20,EFMB21,EFMB22,EFMB23,EFMB24,EFMB25,EFMB26,EFMB27,EFMB28,'
                 'EFMB29,EFMB30,FNMB1,FNMB2,FNMB3,FNMB4,FNMB5,FNMB6,FNMB7,FNMB8,FNMB9,FNMB10,FNMB11,FNMB12,FNMB13,'
                 'FNMB16,FNMB17,FNMB18,FNMB19,FNMB20,FNMB21,FNMB22,FNMB23,FNMB24,FNMB25']
    ward_codes = ['EFMB,FNMB']
    place_patients(db, server, user, password, verbose, bed_codes)
    admit_patients(db, server, user, password, verbose, ward_codes, patient_count=4)
    news_simulation(db, server, user, password, verbose)

@task
def uat_slam_env(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create SLAM (South London & Maudsley Hospital) UAT environment: 30 placed patients in two wards
    and 4 waiting patients
    """
    bed_codes = ['6BN01,6BN02,6BN03,6BN04,6BN05,6BN06,6BN07,6BN08,6BN09,6BN10,6BN11,6BN12,6BN13,'
                 '6BS16,6BS17,6BS18,6BS19,6BS20,6BS21,6BS22,6BS23,6BS24,6BSDC01,6BSDC02,6BSDC03,6BSDC04']
    ward_codes = ['06BN,06BS']
    place_patients(db, server, user, password, verbose, bed_codes)
    admit_patients(db, server, user, password, verbose, ward_codes, patient_count=4)
    news_simulation(db, server, user, password, verbose)

@task
def uat_ldh_env(db, server='http://localhost:8069', user='admin', password='admin', verbose=False):
    """
    Create LDH (Luton & Dunstable Hospital) UAT environment
    """
    bed_codes = ['A01,A02,A03,A04,A05,A06,A07,A08,A09,A10,A11,A12,A13,A14,A15,A16,A17,A18,' \
                'B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B12,B13,B14,B15,B16,B17,B18,' \
                'C01,C02,C03,C04,C05,C06,C07,C08,C09,C10,C11,C12,C13,C14,C15,C16,C17,C18,' \
                'D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11,D12,D13,D14,D15,D16,D17,D18']
    ward_codes = ['A,B,C,D,WEAU,AE,UCC']
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
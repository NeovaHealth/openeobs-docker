# -*- coding: utf-8 -*-
"""
The time_* methods in this module wrap Odoo's execute_kw method exposed via
it's Web Service API.
"""
import erppeek
from erppeek_timer import ErpPeekTimer


quoted_uuid = 'str(uuid.uuid4())'


def transfer_patient_args():
    return quoted_uuid, "{'location': 'B'}"


def create_ews_args():
    return


def get_activities_args():
    return '[]'


def time_nh_eobs_api_complete(database='develop'):
    """
    Create and complete 3 EWS observation activities.
    :param db:
    :return:
    """
    erppeek_client = erppeek.Client(
        'http://localhost:8069', db=database,
        user=admin_login, password=admin_login
    )

    timings = []
    erppeek_timer = ErpPeekTimer('nh.eobs.api', 'complete', nurse_login,
                                 database=database)
    erppeek_timer.log_before(3)
    for x in range(3):
        obs_activity_ids = erppeek_client.execute(
            'nh.activity', 'search',
            [
                ('data_model', '=', 'nh.clinical.patient.observation.ews'),
                ('state', 'not in', ['completed', 'cancelled']),
                ('parent_id', '=', spell_activity_id)
            ]
        )
        obs_activity_id = obs_activity_ids[0]

        timing = erppeek_timer.timeit(
            """
            [
                %s,
                {
                    'respiration_rate': 18,
                    'indirect_oxymetry_spo2': 99,
                    'oxygen_administration_flag': 0,
                    'body_temperature': 37.5,
                    'blood_pressure_systolic': 120,
                    'blood_pressure_diastolic': 80,
                    'pulse_rate': 65,
                    'avpu_text': 'A'
                }
            ]
            """ % str(obs_activity_id),
            repeat=1
        )
        timings.extend(timing)
    erppeek_timer.log_after(timings)


def time_nh_eobs_api_register():
    erppeek_timer = ErpPeekTimer('nh.eobs.api', 'register', admin_login)
    erppeek_timer.timeit_and_log(
        """
        [
            str(uuid.uuid4()),
            {
                'patient_identifier': str(uuid.uuid4()),
                'given_name': 'Jon',
                'family_name': 'Snow',
                'middle_names': 'Maureen',
                'dob': '1989-06-06'
            }
        ]
        """
    )


def time_nh_clinical_wardboard_fields_get():
    erppeek_timer = ErpPeekTimer('nh.clinical.wardboard', 'fields_get', admin_login)
    erppeek_timer.timeit_and_log(
        """
        [],
        {
            'context': {
                'lang': 'en_GB',
                'tz': 'Europe/London',
                'uid': 50,
                'search_default_acuity_index': 1,
                'active_model': 'nh.clinical.wardboard'
            }
        }
        """
    )


def time_nh_clinical_wardboard_fields_view_get():
    erppeek_timer = ErpPeekTimer('nh.clinical.wardboard', 'fields_view_get', admin_login)
    erppeek_timer.timeit_and_log(
        """
        [],
        {
            'view_id': 350,
            'view_type': 'search',
            'context': {
                'lang': 'en_GB',
                'tz': 'Europe/London',
                'uid': 50,
                'search_default_acuity_index': 1,
                'active_model': 'nh.clinical.wardboard'
            },
            'toolbar': False
        }
        """
    )


def time_nh_clinical_wardboard_read_group():
    erppeek_timer = ErpPeekTimer('nh.clinical.wardboard', 'read_group',
                                 admin_login)
    erppeek_timer.timeit_and_log(
        """
        [],
        {
            'groupby': [
                'acuity_index'
            ],
            'fields': [
                "acuity_index",
                "location_full_name",
                "full_name",
                "ews_trend_string",
                "next_diff",
                "location",
                "nhs_number",
                "hospital_number",
                "ews_score_string",
                "dob",
                "age",
                "sex",
                "patient_id",
                "frequency",
                "date_scheduled"
            ],
            'domain': [
                ("spell_state", "=", "started"),
                ("spell_activity_id.user_ids", "in", 50),
                ("location_id.usage", "=", "bed")
            ],
            'context': {
                "lang": "en_GB",
                "tz": "Europe/London",
                "uid": 50,
                "params": {
                  "view_type": "kanban",
                  "model": "nh.clinical.wardboard",
                  "menu_id": 152,
                  "action": 156,
                  "_push_me": False
                },
                "search_default_acuity_index": 1,
                "group_by": "acuity_index"
            },
            'offset': 0,
            'lazy': True,
            'limit': False,
            'orderby': False
        }
        """
    )


def time_nh_clinical_wardboard_search_read(database='develop'):
    erppeek_timer = ErpPeekTimer('nh.clinical.wardboard', 'search_read',
                                 admin_login, database=database)
    erppeek_timer.timeit_and_log(
        """
        [
            [
                ("acuity_index", "=", "Medium"),
                ("spell_state", "=", "started"),
                ("spell_activity_id.user_ids", "in", 50),
                ("location_id.usage", "=", "bed")
            ]
        ],
        {
            "fields": [
                "location_full_name",
                "full_name",
                "ews_trend_string",
                "next_diff",
                "location",
                "nhs_number",
                "hospital_number",
                "ews_score_string",
                "dob",
                "age",
                "sex",
                "patient_id",
                "frequency",
                "date_scheduled",
                "acuity_index",
                "__last_update"
            ],
            "context": {
                "lang": "en_GB",
                "tz": "Europe/London",
                "uid": 50,
                "search_default_acuity_index": 1,
                "group_by": []
            },
            "offset": 0,
            "limit": 40
        }
        """
    )


def time_res_users_has_group():
    erppeek_timer = ErpPeekTimer('res.users', 'has_group',
                                 admin_login)
    erppeek_timer.timeit_and_log(
        """
        ["base.group_user"]
        """
    )


def time_res_users_read():
    erppeek_timer = ErpPeekTimer('res.users', 'read',
                                 admin_login)
    erppeek_timer.timeit_and_log(
        """
        [
            50,
            ['name', 'company_id']
        ]
        """
    )


def time_nh_eobs_ward_dashboard_fields_view_get():
    erppeek_timer = ErpPeekTimer('nh.eobs.ward.dashboard', 'fields_view_get',
                                 admin_login)
    erppeek_timer.timeit_and_log(
        """
        [],
        {
            'view_id': 396,
            'view_type': 'kanban',
            'context': {
                "lang": "en_GB",
                "tz": "Europe/London",
                "uid": 50,
                "params": {
                  "view_type": "kanban",
                  "model": "nh.eobs.ward.dashboard",
                  "menu_id": 162,
                  "action": 178,
                  "_push_me": False
                },
                'active_model': 'nh.eobs.ward.dashboard'
            },
            'toolbar': True
        }
        """
    )


def time_nh_eobs_ward_dashboard_fields_get():
    erppeek_timer = ErpPeekTimer('nh.eobs.ward.dashboard', 'fields_get',
                                 admin_login)
    erppeek_timer.timeit_and_log(
        """
        [],
        {
            'context': {
                "lang": "en_GB",
                "tz": "Europe/London",
                "uid": 50,
                "params": {
                  "view_type": "kanban",
                  "model": "nh.eobs.ward.dashboard",
                  "menu_id": 162,
                  "action": 178,
                  "_push_me": False
                },
                'active_model': 'nh.eobs.ward.dashboard'
            }
        }
        """
    )


def time_nh_eobs_ward_dashboard_search_read():
    erppeek_timer = ErpPeekTimer('nh.eobs.ward.dashboard', 'search_read',
                                 admin_login)
    erppeek_timer.timeit_and_log(
        """
        [
            [('user_ids', 'in', 50)]
        ],
        {
            "fields": [
                "related_nurses",
                "no_risk_patients",
                "low_risk_patients",
                "kanban_color",
                "noscore_patients",
                "assigned_wm_ids",
                "location_id",
                "related_hcas",
                "capacity_count",
                "workload_count",
                "med_risk_patients",
                "extended_leave_count",
                "awol_count",
                "assigned_doctor_ids",
                "high_risk_patients",
                "patients_in_bed",
                "name",
                "waiting_patients",
                "acute_hospital_ed_count",
                "related_doctors",
                "on_ward_count",
                "refused_obs_count",
                "__last_update"
            ],
            "context": {
                "lang": "en_GB",
                "tz": "Europe/London",
                "uid": 50,
                "params": {
                  "view_type": "kanban",
                  "model": "nh.eobs.ward.dashboard",
                  "menu_id": 162,
                  "action": 178,
                  "_push_me": False
                }
            },
            "offset": 0,
            "limit": 40
        }
        """
    )


#==~ Setup ~===============================================================
admin_login = 'admin'
erppeek_client_admin = erppeek.Client('http://localhost:8069',
                                      db='develop',
                                      user=admin_login,
                                      password=admin_login)
spell_activities = erppeek_client_admin.execute(
    'nh.activity', 'search', [('data_model', '=', 'nh.clinical.spell')]
)
spell_activity_id = spell_activities[0]
spell_activity = erppeek_client_admin.execute('nh.activity', 'read',
                                              spell_activity_id)
# spell_id = int(spell_activity['data_ref'].split(',')[1])
# spell = erppeek_client.execute('nh.clinical.spell', 'read', spell_id)
# patient_id = spell['patient_id'][0]
# patient = erppeek_client.execute('nh.clinical.patient', 'read', patient_id)
location_id = spell_activity['location_id'][0]
location = erppeek_client_admin.execute('nh.clinical.location', 'read',
                                        location_id)
nurse_id = location['assigned_nurse_ids'][0]
nurse = erppeek_client_admin.execute('res.users', 'read', nurse_id)
nurse_login = nurse['login']
erppeek_client_nurse = erppeek.Client('http://localhost:8069',
                                      db='develop',
                                      user=nurse_login,
                                      password=nurse_login)

if __name__ == "__main__":
    #==~ Time Methods ~========================================================
    # erppeek_timer.timeit_and_log(*(transfer_patient_args()))

    # erppeek_timer = ErpPeekTimer('nh.eobs.api', 'get_activities', nurse_login)
    # erppeek_timer.timeit_and_log(get_activities_args())

    time_nh_eobs_api_register()
    time_nh_eobs_api_complete()

    time_nh_clinical_wardboard_fields_view_get()
    time_nh_clinical_wardboard_fields_get()
    time_nh_clinical_wardboard_read_group()
    time_nh_clinical_wardboard_search_read()

    time_res_users_has_group()
    time_res_users_read()
    time_nh_eobs_ward_dashboard_fields_view_get()
    time_nh_eobs_ward_dashboard_fields_get()
    time_nh_eobs_ward_dashboard_search_read()
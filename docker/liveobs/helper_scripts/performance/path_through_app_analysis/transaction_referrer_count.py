""" Iterate through a list of URLS and return a count of pages visted after"""
import requests, json
# Change this to point at whatever IP Piwik is running under
URL = 'http://192.168.33.10/piwik/index.php'
# AUTH_TOKEN may change so need to update this with one taken from network
# panel in Chrome dev tools (get from API call in browser)
AUTH_TOKEN = {"token_auth": "e1353e87289653bdc81fe24cad4858c3"}
pages_to_get_stats_for = {
   'task_list': [
        'mobile/tasks/',
        'mobile/tasks'
    ],
    'patient_list': [
        'mobile/patients',
        'mobile/patients/'
    ],
    'login': [
        'mobile/login'
    ]
}
PARAMETERS = {
    'date': '2017-02-26,2017-04-22',
    'actionType': 'url',
    'actionName': 'http://eobs.slam.nhs.uk/{0}',
    'expanded': 1,
    'format': 'JSON',
    'module': 'API',
    'method': 'Transitions.getTransitionsForAction',
    'filter_limit': -1,
    'idSite': 2,
    'period': 'range',
    'limitBeforeGrouping': 0
}
for title, pages in pages_to_get_stats_for.iteritems():
    from_task_page = 0
    from_obs_page = 0
    from_patient_page = 0
    from_patient_obs_page = 0
    from_login_page = 0
    for page in pages:
        params = PARAMETERS.copy()
        params['actionName'] = params['actionName'].format(page)
        request = requests.post(URL, params=params, data=AUTH_TOKEN)
        response = request.json()
        previous_pages = response.get('previousPages', [])
        for previous_page in previous_pages:
            label = previous_page.get('label')
            count = int(previous_page.get('referrals'))
            if '/mobile/task/' in label:
                from_task_page += count
            if '/api/v1/tasks/' in label:
                from_obs_page += count
            if 'api/v1/patient/submit' in label:
                from_patient_obs_page += count
    print '---{}---'.format(title)
    print 'From Task List: {}'.format(from_task_page)
    print 'From Patient List: {}'.format(from_patient_page)
    print 'From Observation via Task: {}'.format(from_obs_page)
    print 'From Observation via Patient: {}'.format(from_patient_obs_page)

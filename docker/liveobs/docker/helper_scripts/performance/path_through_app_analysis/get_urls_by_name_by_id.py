"""
Do a search on a particular substring in a page URL and get a count of each
escalation task (based on task summary) type the user went directly to after
visiting the page
"""
import MySQLdb, requests

task_map = {}
task_summaries = []
task_ids = {}
# Change this to filter on task name
escalation_task = 'Call An Ambulance 2222/9999'

# task_summaries is a list of {id: xxxx, summary: 'activity name'} from ERPPeek
with open('task_summaries.txt') as txtfile:
    task_file = txtfile.read()
    task_summaries = eval(task_file)

# task_summaries_as_dict is a task id -> task summary map
with open('task_summaries_as_dict.txt') as mapfile:
    map_file = mapfile.read()
    task_map = eval(map_file)

for task in task_summaries:
    if task_ids.get(task.get('summary')):
        task_ids[task.get('summary')].append(task.get('id'))
    else:
        task_ids[task.get('summary')] = [task.get('id')]

def get_label(raw_label):
    """
    Given a page name (label) return the key we want to add this page under
    """
    first_slash = raw_label.index('/')
    label = raw_label[first_slash:]
    last_slash = raw_label.rindex('/')
    try:
        task_id = int(raw_label[(last_slash + 1):])
    except:
        task_id = None
    task_summary = task_map.get(task_id, label)
    return task_summary

database = MySQLdb.connect('localhost', 'root', 'password', 'piwik')
cursor = database.cursor()
task_urls = []
escalation_task_ids = task_ids.get(escalation_task)
for task_id in escalation_task_ids:
    cursor.execute("SELECT name FROM `piwik_log_action` WHERE `name` "
                   "LIKE '%_clinical/%' AND `name` LIKE "
                   "'%{}%';".format(task_id))
    task_row = cursor.fetchone()
    if task_row:
        task_urls.append(task_row[0])
database.close()
prev_pages = {}
nxt_pages = {}
for task_url in task_urls:
    # Whatever URL piwik sits under
    URL = 'http://192.168.33.10/piwik/index.php'
    # AUTH_TOKEN may change so need to get another by inspecting an API call
    # from Piwik GUI in Network Tab in Chrome's Dev Tools
    AUTH_TOKEN = {"token_auth": "e1353e87289653bdc81fe24cad4858c3"}
    PARAMETERS = {
        'date': '2017-02-26,2017-04-22',
        'actionType': 'url',
        'actionName': task_url,
        'expanded': 1,
        'format': 'JSON',
        'module': 'API',
        'method': 'Transitions.getTransitionsForAction',
        'filter_limit': -1,
        'idSite': 2,
        'period': 'range',
        'limitBeforeGrouping': 0
    }
    request = requests.post(URL, params=PARAMETERS, data=AUTH_TOKEN)
    response = request.json()
    previous_pages = response.get('previousPages', [])
    next_pages = response.get('followingPages', [])
    for previous_page in previous_pages:
        raw_label = previous_page.get('label')
        label = get_label(raw_label)
        count = int(previous_page.get('referrals'))
        prev_pages[label] = prev_pages.get(label, 0) + count
    for next_page in next_pages:
        raw_label = next_page.get('label')
        label = get_label(raw_label)
        count = int(next_page.get('referrals'))
        nxt_pages[label] = nxt_pages.get(label, 0) + count
print '---- {} ---'.format(escalation_task)
print 'Came from: {}'.format(prev_pages)
print 'Went to: {}'.format(nxt_pages)

"""
Given a file with an list of the returned {id: XXXX, summary: 'activity name'}
from ERPPpeek turn it into a dict with key = id and value = summary and save
to task_summaries_as_dict
"""
task_summaries = {}
task_ids = []

with open('task_summaries.txt') as txtfile:
    task_file = txtfile.read()
    task_ids = eval(task_file)
    for task in task_ids:
        task_summaries[task.get('id')] = task.get('summary')

with open('task_summaries_as_dict.txt', 'wb') as sumfile:
    sumfile.write('{}'.format(task_summaries))

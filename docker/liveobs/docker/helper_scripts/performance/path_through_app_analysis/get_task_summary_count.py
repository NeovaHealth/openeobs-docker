
task_summaries = []
task_count = {}
task_ids = {}
with open('task_summaries.txt') as txtfile:
	task_file = txtfile.read()
	task_summaries = eval(task_file)

for task in task_summaries:
	task_count[task.get('summary')] = task_count.get(task.get('summary'), 0) + 1
	if task_ids.get(task.get('summary')):
		task_ids[task.get('summary')].append(task.get('id'))
	else:
		task_ids[task.get('summary')] = [task.get('id')]

print task_count
print '----------------------------'
print task_ids
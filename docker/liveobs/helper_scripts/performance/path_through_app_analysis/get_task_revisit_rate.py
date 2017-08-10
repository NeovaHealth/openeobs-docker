import MySQLdb, requests

task_summaries = []
task_ids = {}
with open('task_summaries.txt') as txtfile:
	task_file = txtfile.read()
	task_summaries = eval(task_file)

database = MySQLdb.connect('localhost', 'root', 'password', 'piwik')
cursor = database.cursor()
for task in task_summaries:
	cursor.execute("SELECT count(*) FROM `piwik_log_action` WHERE `name` LIKE '%_clinical/%' AND `name` LIKE '%{}%';".format(task.get('id')))
	row = cursor.fetchone()
	if not task_ids.get(task.get('summary')):
		task_ids[task.get('summary')] = []
	if row:
		task_ids[task.get('summary')].append(row[0])
	else:
		task_ids[task.get('summary')].append(0)
database.close()

for key, value in task_ids.iteritems():
	print '{0}: {1}/{2}x100 = {3}'.format(key, sum(value), len(value), ((float(sum(value))/float(len(value))*100.0)))
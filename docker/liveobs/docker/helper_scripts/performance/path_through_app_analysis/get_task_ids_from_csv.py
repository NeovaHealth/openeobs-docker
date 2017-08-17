""" 
Given an export of tasks from Piwik on the Actions -> Pages page that's called
task_ids.csv process it into a Python list and save it into a file for easy
copy and pasting into ERPPeek when getting summaries.
"""
import csv

task_ids = []

with open('task_ids.csv') as csvfile:
    csvread = csv.reader(csvfile)
    for row in csvread:
        url = row[0].rindex('/') + 1
        task_id = int(row[0][url:])
        task_ids.append(task_id)

with open('task_ids.txt', 'wb') as txtfile:
    txtfile.write('task_ids = {}'.format(task_ids))

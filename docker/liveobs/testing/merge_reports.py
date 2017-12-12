from xml.etree import ElementTree as et
import os

testsuites = et.Element("testsuites")
for test_report in os.listdir('test_results'):
    report_tree = et.parse("test_results/{}".format(test_report))
    report_root = report_tree.getroot()
    for testsuite in report_root:
        testsuites.append(testsuite)
test_report = et.ElementTree(testsuites)
test_report.write('xunit-report.xml')

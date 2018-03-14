"""
Parses the `unit_test.log` created by the `run_unit_tests` rule in the
Makefile to determine whether the unit tests passed or failed and return an
appropriate exit code.
"""
import sys, subprocess, time, re, string
from datetime import datetime
from xunitgen import XunitDestination, EventReceiver, toxml

destination = XunitDestination('./test_results')
receiver = None
test_time = 0
TEST_CASE_REGEX = re.compile(r".*\|.* (\d+-\d+-\d+ \d+:\d+:\d+,\d+).*: ([a-zA-Z0-9_]+) \(([a-zA-Z0-9\._]+)\)")
TEST_END_REGEX = re.compile(r".*\|.* (\d+-\d+-\d+ \d+:\d+:\d+,\d+).* (.+): Ran (\d+) test(s)? in ([0-9\.]+)")
TEST_FAIL_REGEX = re.compile(r".*\|.* (\d+-\d+-\d+ \d+:\d+:\d+,\d+).*([a-zA-Z0-9_]+): FAIL")
failing_tests = []


def get_timestamp(date_string):
    """
    Get the seconds since unix epoch from the date_string

    :param date_string: Date in %Y-%m-%d %H:%M:%S,%f format from the log
    """
    return float(datetime.strptime(date_string, '%Y-%m-%d %H:%M:%S,%f').strftime('%S'))


with open('unit_test.log', 'rb') as log_file:
    for line in log_file:
        all_bytes = string.maketrans('', '')
        line = line.translate(all_bytes, all_bytes[:32])
        if 'running tests' in line:
            receiver = EventReceiver()
        if 'test_' in line and '(openerp.addons.' in line:
            line_match = TEST_CASE_REGEX.match(line).groups()
            test_time = get_timestamp(line_match[0])
            test_name = line_match[1].replace('openerp.addons.', '')
            test_location = line_match[2].replace('openerp.addons.', '')
            if receiver.current_case:
                receiver.end_case(receiver.current_case.name, test_time)
            receiver.begin_case(test_name, test_time, test_location)
        if ': Ran ' in line and 'test' in line and ' in ' in line:
            print line
            line_match = TEST_END_REGEX.match(line).groups()
            if receiver.current_case:
                test_time = get_timestamp(line_match[0])
                receiver.end_case(receiver.current_case.name, test_time)
            test_name = line_match[1]
            test_results = receiver.results()
            package_name_els = test_name.split('.')
            suite_name = "{}.py".format(package_name_els[-1])
            package_name = '/'.join(package_name_els[2:-1])
            test_name = test_name.replace('openerp.addons.', '')
            destination.write_reports(
                test_name, suite_name, test_results, package_name=package_name)
        if line[:6] == ': FAIL':
            line_match = TEST_FAIL_REGEX.match(line).groups()
            test_name = line_match[1].replace('openerp.addons.', '')
            receiver.failure('', line_match[1])
        if 'FAIL:' in line or 'ERROR:' in line:
            failing_tests.append(line)
        if 'Initiating shutdown' in line:
            if failing_tests:
                sys.stdout.write(
                    '--------------------FAILING TESTS------------------------'
                    '--\n'
                )
                for test in failing_tests:
                    sys.stdout.write(' - {}\n'.format(test))
                sys.exit(1)
            else:
                sys.exit(0)

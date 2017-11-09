import sys, subprocess, time, re
from xunitgen import XunitDestination, EventReceiver, toxml

destination = XunitDestination('/opt/odoo')
receiver = xunitgen.EventReceiver()
TEST_START_REGEX = re.compile(r"\.* openerp\.modules\.module: (.*) running tests\.")
TEST_CASE_REGEX = re.compile(r"\.*: ([a-zA-z_]+) \(([a-zA-z\._]+)\)")
TEST_END_REGEX = re.compile(r"\.*([a-z\._]+): Ran (\d+) tests in ([0-9\.]+)")
failing_tests = []

while 1:

    try:
        line = sys.stdin.readline()
        if 'running tests' in line:
            test_name = TEST_START_REGEX.match(line).groups()[0]
            test_location = test_name.replace('openerp.addons.', '').replace('.', '/')
            receiver.being_case(test_name, 0, test_location)
            sys.stdout.write("Began test case")
        if 'Ran' in line and 'tests' in line:
            line_match = TEST_END_REGEX.match(line).groups()
            test_name = line_match[0]
            number_of_tests = line_match[1]
            test_time = float(line_match[2])
            receiver.end_case(test_name, test_time)
            sys.stdout.write("Ended test case")
        if 'FAIL:' in line:
            failing_tests.append(line)
            receiver.failure('', '')
        # if 'openerp.modules.loading: All post-tested' in line:
        if 'Initiating shutdown' in line:
            time.sleep(2)
            test_results = receiver.results()
            destination.write_reports('/opt/nh/unit_test_results.xml', 'testsuite', test_results)
            if failing_tests:
                sys.stdout.write('--------------------FAILING TESTS--------------------------\n')
                for test in failing_tests:
                    sys.stdout.write(' - {}\n'.format(test))
                sys.exit(1)
            else:
                sys.exit(0)
    except KeyboardInterrupt:
        break

    if not line:
        break

    sys.stdout.write(line)

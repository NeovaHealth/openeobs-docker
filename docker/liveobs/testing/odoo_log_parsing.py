import sys, subprocess, time, re
from xunitgen import XunitDestination, EventReceiver, toxml

destination = XunitDestination('.')
receiver = EventReceiver()
TEST_START_REGEX = re.compile(r".* openerp\.modules\.module: (.*) running tests\.")
TEST_CASE_REGEX = re.compile(r".*: ([a-zA-z_]+) \(([a-zA-z\._]+)\)")
TEST_END_REGEX = re.compile(r".* (.+): Ran (\d+) test(s)? in ([0-9\.]+)")
failing_tests = []

while 1:

    try:
        line = sys.stdin.readline()
        if 'running tests' in line:
            test_name = TEST_START_REGEX.match(line).groups()[0]
            test_location = test_name.replace('openerp.addons.', '').replace('.', '/')
            receiver.begin_case(test_name, 0, test_location)
        if 'Ran' in line and 'tests' in line:
            sys.stdout.write("LINE: {}".format(line))
            line_match = TEST_END_REGEX.match(line).groups()
            test_name = line_match[0]
            number_of_tests = line_match[1]
            test_time = float(line_match[3])
            receiver.end_case(test_name, test_time)
        if 'FAIL:' in line:
            failing_tests.append(line)
            receiver.failure('', '')
        # if 'openerp.modules.loading: All post-tested' in line:
        if 'Initiating shutdown' in line:
            time.sleep(2)
            test_results = receiver.results()
            destination.write_reports('unit_test_results', 'testsuite', test_results)
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

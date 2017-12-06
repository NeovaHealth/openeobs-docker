import sys, subprocess, time, re
from xunitgen import XunitDestination, EventReceiver, toxml

destination = XunitDestination('./test_results')
receiver = None
TEST_START_REGEX = re.compile(r".* openerp\.modules\.module: (.*) running tests\.")
TEST_CASE_REGEX = re.compile(r".*: ([a-zA-Z0-9_]+) \(([a-zA-Z0-9\._]+)\)")
TEST_END_REGEX = re.compile(r".* (.+): Ran (\d+) test(s)? in ([0-9\.]+)")
failing_tests = []

while 1:

    try:
        line = sys.stdin.readline()
        if 'running tests' in line:
            receiver = EventReceiver()
        if 'test_' in line and '(openerp.addons.' in line:
            sys.stdout.write("LINE: {}".format(line))
            test_name = TEST_CASE_REGEX.match(line).groups()[0]
            test_location = TEST_CASE_REGEX.match(line).groups()[1]
            receiver.begin_case(test_name, 0, test_location)
            receiver.end_case(test_name, 0)
        if 'Ran' in line and 'tests' in line:
            line_match = TEST_END_REGEX.match(line).groups()
            test_name = line_match[0]
            test_results = receiver.results()
            package_name_els = test_name.split('.')
            package_name = '.'.join(package_name_els[:3])
            destination.write_reports(test_name, test_name, test_results, package_name=package_name)
        if 'FAIL:' in line:
            failing_tests.append(line)
            receiver.failure('', '')
        # if 'openerp.modules.loading: All post-tested' in line:
        # if 'Initiating shutdown' in line:
        #     sys.stdout.write('About to shut down')
        #     if failing_tests:
        #         sys.stdout.write('--------------------FAILING TESTS--------------------------\n')
        #         for test in failing_tests:
        #             sys.stdout.write(' - {}\n'.format(test))
        #         sys.exit(1)
        #     else:
        #         sys.exit(0)
    except KeyboardInterrupt:
        break

    if not line:
        break

    sys.stdout.write(line)

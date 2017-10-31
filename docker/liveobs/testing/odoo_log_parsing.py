import sys, subprocess, time

failing_tests = []

while 1:

    try:
        line = sys.stdin.readline()
        if 'FAIL:' in line:
            failing_tests.append(line)
        # if 'openerp.modules.loading: All post-tested' in line:
        if 'Initiating shutdown' in line:
            # find_file = subprocess.Popen(["docker", "exec", "-u", "odoo", "liveobs_web_1", "ls", "/opt/nh"])
            # coverage = subprocess.Popen(["docker", "exec", "-u", "odoo", "liveobs_web_1", "/opt/nh/venv/bin/coverage", "xml", "-o", "/opt/nh/unit_test_coverage.xml"])
            # for cov_out, cov_err in coverage.commnicate():
            #     sys.stdout.write(cov_out)
            # subprocess.Popen(["docker", "exec", "web", "collect-coverage"], stdout=subprocess.PIPE)
            # collect = subprocess.Popen(["docker", "cp", "web:/opt/nh/unit_test_coverage.xml", "unit_test_coverage"], stdout=subprocess.PIPE)
            # sys.stdout.write(collect.communicate())
            # stop = subprocess.Popen(["docker-compose", "stop", "web"], stdout=subprocess.PIPE)
            # sys.stdout.write(stop.communicate())
            time.sleep(2)
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

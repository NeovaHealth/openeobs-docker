import sys, subprocess, time

failing_tests = []

for line in sys.stdin:
    sys.stdout.write(line)
    if 'FAIL:' in line:
        failing_tests.append(line)
    if 'Initiating shutdown' in line:
        subprocess.Popen(["docker", "exec", "liveobs_web_1", "/opt/nh/venv/bin/coverage", "xml", "-o", "/opt/nh/unit_test_coverage.xml"], stdout=subprocess.PIPE)
        # subprocess.Popen(["docker", "exec", "web", "collect-coverage"], stdout=subprocess.PIPE)
        subprocess.Popen(["docker", "cp", "web:/opt/nh/unit_test_coverage.xml", "unit_test_coverage"], stdout=subprocess.PIPE)
        subprocess.Popen(["docker-compose", "stop", "web"], stdout=subprocess.PIPE)
        time.sleep(2)
        if failing_tests:
            sys.stdout.write('--------------------FAILING TESTS--------------------------\n')
            for test in failing_tests:
                sys.stdout.write(' - {}\n'.format(test))
            sys.exit(1)
        else:
            sys.exit(0)

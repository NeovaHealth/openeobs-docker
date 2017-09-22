import sys, subprocess, time

failing_tests = []

for line in sys.stdin:
    sys.stdout.write(line)
    if 'FAIL:' in line:
        failing_tests.append(line)
    if 'Initiating shutdown' in line:
        subprocess.Popen(["docker-compose", "stop", "web"], stdout=subprocess.PIPE)
        time.sleep(2)
        if failing_tests:
            sys.stdout.write('--------------------FAILING TESTS--------------------------\n')
            for test in failing_tests:
                sys.stdout.write(' - {}\n'.format(test))
            sys.exit(1)
        else:
            sys.exit(0)

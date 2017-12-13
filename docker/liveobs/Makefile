#!/usr/bin/make

OS = $(shell uname)
ifeq ($(OS), Linux)
VENV_PIP_PATH = 'bin/pip'
else
VENV_PIP_PATH = 'Scripts/pip'
endif

REGION = $(shell echo ${registry} | awk -F. '{print $$4}')

# Skips the reading of the file if VERSION is already defined.
# Allows running locally like `VERSION=foo make run_server`
ifndef VERSION
VERSION = $(shell echo `cat version_branch.txt`)
endif

all: build test publish create_client_db
unit_test_on_gocd: stop_server clean get_sql_dump run_unit_tests

clean:
	@echo -n "Checking for registry setting ... "
	@test -n "${registry}" || (echo "no registry setting" && exit 1)
	@echo OK
	docker rmi ${registry}/liveobs:${VERSION} || true
	docker rmi ${registry}/liveobs:latest || true
	docker rmi liveobs:${VERSION} || true

login:
	@echo -n "Checking for registry setting ... "
	@test -n "${registry}" || (echo "no registry setting" && exit 1)
	@echo OK
	@echo -n "Logging into ECR..."
	@`aws ecr get-login --no-include-email --region "${REGION}"`

prebuild:
	mv ${addons_path}/client_modules/addons/* ${addons_path}/nhclinical/addons/* ${addons_path}/openeobs/addons/* liveobs_addons
	mv liveobs_addons docker/

create_addons_dir:
	@mkdir -p liveobs_addons

build: clean login
	cd docker && docker build --pull --no-cache -t ${registry}/liveobs:${VERSION} -f Dockerfile .
	docker tag ${registry}/liveobs:${VERSION} liveobs:${VERSION}
	@cd ..

create_client_db: login
	# Build an image with the files necessary to build a demo database with invoke scripts, dump to SQL file, and push it to S3 for any test instances to use.
	@cd testing && docker build -t liveobs-testing:${VERSION} -f Dockerfile-testing --build-arg version=${VERSION} . && cd ..
	docker-compose rm -f
	# Bring up the container and tell it to run the create DB script.
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-initdb.yml up --abort-on-container-exit
	@docker rmi liveobs-testing:${VERSION}

get_sql_dump:
	mkdir -p db_dumps
	aws s3 cp "s3://liveobs-provisioning-eu-west-1/artifacts/odoo/dbs/${VERSION}/liveobs.sql" db_dumps/liveobs.sql

run_server: login get_sql_dump
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml up -d db
	sleep 15
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml up -d --no-build web

run_integration_server: login
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml up -d db
	sleep 15
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml up -d --no-build web

stop_server:
	# Stop containers specified in the `docker-compose.yml` file then remove them.
	docker-compose rm --stop -f

collect_unit_test_coverage:
	virtualenv venv
	venv/bin/pip install awscli && aws s3 cp "s3://liveobs-build/artifacts/odoo/coverage/${VERSION}/unit_test_coverage.xml" unit_test_coverage.xml

run_unit_tests: login
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml up -d db
	sleep 15
	VERSION=${VERSION} docker-compose \
		-f docker-compose.yml \
		-f docker-compose-liveobs-server.yml \
		-f docker-compose-unit-test.yml up web \
		| tee unit_test.log

create_unit_test_report:
	python testing/create_reports.py
	python testing/merge_reports.py

run_unit_tests_coverage:
	sed -i "s/__VERSION__/${VERSION}/" testing/Dockerfile-coverage
	@cd testing && docker build -t liveobs-coverage:${VERSION} -f Dockerfile-coverage . && cd ..
	@mkdir test_results
	docker-compose rm -f
	VERSION=${VERSION} docker-compose \
		-f docker-compose.yml \
		-f docker-compose-liveobs-server.yml \
		-f docker-compose-unit-test-coverage.yml build db
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose-liveobs-server.yml \
		-f docker-compose-unit-test-coverage.yml up -d db
	sleep 15
	VERSION=${VERSION} docker-compose \
		-f docker-compose.yml \
		-f docker-compose-liveobs-server.yml \
		-f docker-compose-unit-test-coverage.yml up web \
		| tee unit_test.log

test:
	@echo "FROM ${registry}/liveobs:${VERSION}\nCMD /bin/bash" > Dockerfile-rspec
	@docker build -t liveobs-rspec:${VERSION} -f Dockerfile-rspec .
	@bundle install
	@VERSION=${VERSION} bundle exec rake spec
	@rm -rf vendor
	@docker rmi liveobs-rspec:${VERSION}

publish: login
	@echo -n "Checking for registry setting ... "
	@test -n "${registry}" || (echo "no registry setting" && exit 1)
	@echo OK
	@docker push ${registry}/liveobs:${VERSION}

publish_latest: login
	@echo -n "Checking for registry setting ... "
	@test -n "${registry}" || (echo "no registry setting" && exit 1)
	@echo OK
	@docker tag ${registry}/liveobs:${VERSION} ${registry}/liveobs:latest
	@docker push ${registry}/liveobs:latest

reset_demo_data_with_invoke_scripts:
	# Container must be running before you run this script.
	echo "Not yet implemented."

reset_demo_data_with_sql_file:
	# Container must be running before you run this script.
	echo "Not yet implemented."

.PHONY: create_addons_dir clean login build test publish create_client_db run_unit_tests_coverage

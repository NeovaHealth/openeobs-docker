#!/usr/bin/make

OS = $(shell uname)
ifeq ($(OS), Linux)
VENV_PIP_PATH = 'bin/pip'
else
VENV_PIP_PATH = 'Scripts/pip'
endif

# Skips the reading of the file if VERSION is already defined.
# Allows running locally like `VERSION=foo make run_server`
ifndef VERSION
VERSION = $(shell echo `cat version_branch.txt`)
endif

# Test if version has build number suffix.
VERSION_INCLUDES_BUILD_NUMBER=$(shell echo $(VERSION) | egrep _[0-9]+$)
# If there is a build number suffix create a version without it.
LATEST_VERSION=$(shell echo $(VERSION) | sed -E 's/_[0-9]+//')

DB=db

REGION = $(shell echo ${registry} | awk -F. '{print $$4}')

all: build test publish create_client_db
unit_test_on_gocd: stop_server clean get_sql_dump run_unit_tests

check_for_registry_settings:
	@echo -n "Checking for registry setting ... "
	@test -n "${registry}" || (echo "no registry setting" && exit 1)
	@echo OK

clean: check_for_registry_settings
	docker rmi ${registry}/liveobs:${VERSION} || true
	docker rmi ${registry}/liveobs:latest || true

login: check_for_registry_settings
	@echo -n "Logging into ECR..."
	@`aws ecr get-login --no-include-email --region "${REGION}"`

# TODO This target depends on their being a populated
# `docker/liveobs/docker/liveobs_addons` directory. That step is done in
# maintainer-quality tools, so bring 'move_addons_into_dir' target from `
# maintainer-quality-tools/gocd/Makefile` into this Makefile and make it a
# dependency of this 'build' target.
build: clean login create_server_config
	docker build --pull --no-cache \
	-t ${registry}/liveobs:${VERSION} \
	--build-arg VERSION=${VERSION} \
	./docker

create_client_db: login
	docker-compose rm -f
# Build an image with the files necessary to build a demo database with invoke scripts, dump to SQL file, and push it to S3 for any test instances to use.
	docker build -t liveobs-testing:${VERSION} \
	-f ./testing/Dockerfile-testing \
	--build-arg version=${VERSION} \
	./testing

# Bring up the container and tell it to run the create DB script.
	VERSION=${VERSION} docker-compose \
	-f docker-compose.yml \
	-f docker-compose-initdb.yml up \
	--abort-on-container-exit

	docker-compose rm -f
	@docker rmi liveobs-testing:${VERSION}

get_sql_dump:
	mkdir -p db_dumps
	aws s3 cp "s3://liveobs-provisioning-eu-west-1/artifacts/odoo/dbs/${VERSION}/liveobs.sql" db_dumps/liveobs.sql

ifndef LOG_HANDLER
LOG_HANDLER=:DEBUG
# Can set this env var to `:DEBUG,openerp.sql_db:DEBUG` for SQL debugging.
endif
create_server_config:
	cp ./docker/server_config_template.cfg ./docker/server.cfg
	sed -i 's/__LOG_HANDLER__/${LOG_HANDLER}/g' ./docker/server.cfg

# Runs LiveObs and loads db_dumps/liveobs.sql into the database.
run_server: login get_sql_dump
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml build db

	docker-compose \
	-f docker-compose.yml \
	-f docker-compose-liveobs-server.yml \
	-f docker-compose-postgres-load-db-dump.yml \
	up -d db
	sleep 15

	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml up -d --no-build web

# Runs invoke scripts against a running LiveObs to rebuild the demo data.
# There are various benefits over loading demo data from a database dump.
# One is that observations will not be overdue because they are newly created.
#
# THERE IS A KNOWN LIMITATION: This target fails when run a second time
# against the same database. Restarting the server fixes this which is why
# `stop_server` is run first.
run_server_and_rebuild_demo_data: stop_server
# Used docker-compose because it supports relative paths for volume mounts.
# Regular docker demands absolute paths.
	docker-compose \
	-f docker-compose.yml \
	-f docker-compose-liveobs-server.yml \
	up -d web
	sleep 30

	DB=${DB} docker-compose -f rebuild_demo_data/docker-compose.yml \
	run --rm invoke_script_runner

run_integration_server: login
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml up -d db
	sleep 15
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml up -d --no-build web

run_server_with_ldap: login
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-integration-test.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server-with-ldap.yml up -d db
	sleep 15
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server-with-ldap.yml up -d --no-build web
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server-with-ldap.yml up -d --no-build ldap
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server-with-ldap.yml up -d --no-build phpldapadmin

stop_server:
# Stop containers specified in the `docker-compose.yml` file then remove them.
	docker-compose stop
	docker-compose rm -f

collect_unit_test_coverage:
	virtualenv venv
	venv/bin/pip install awscli && aws s3 cp "s3://liveobs-build/artifacts/odoo/coverage/${VERSION}/unit_test_coverage.xml" unit_test_coverage.xml

run_unit_tests: login
	docker-compose rm -f
	docker pull ${registry}/liveobs:${VERSION}
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml up -d db
	sleep 60
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
	sleep 60
	VERSION=${VERSION} docker-compose \
		-f docker-compose.yml \
		-f docker-compose-liveobs-server.yml \
		-f docker-compose-unit-test-coverage.yml up web \
		| tee unit_test.log

test:
	docker build -t liveobs-rspec:${VERSION} -f spec/Dockerfile-rspec \
		--build-arg registry=${registry} \
		--build-arg VERSION=${VERSION} .
	bundle install
	VERSION=${VERSION} bundle exec rake spec
	rm -rf vendor
	docker rmi liveobs-rspec:${VERSION}

publish: check_for_registry_settings login
# Versions like `awesome-feature_54` make it difficult for team members to
# pull down the latest version of that feature because they need to lookup
# the latest build number. Adding an extra tag without the build number
# suffix allows the latest image to be easily pulled with a simple
# canonical tag like: `awesome-feature`
ifeq ($(VERSION_INCLUDES_BUILD_NUMBER),)
# Version does not include build number.
	docker push ${registry}/liveobs:${VERSION}
else
# Version includes build number.
	docker tag ${registry}/liveobs:${VERSION} ${registry}/liveobs:${LATEST_VERSION}
	docker push ${registry}/liveobs:${VERSION}
	docker push ${registry}/liveobs:${LATEST_VERSION}
endif

# TODO Is this used anywhere?
publish_latest: check_for_registry_settings login
	@docker tag ${registry}/liveobs:${VERSION} ${registry}/liveobs:latest
	@docker push ${registry}/liveobs:latest

.PHONY: check_for_registry_settings clean login build test publish create_client_db run_unit_tests_coverage rebuild_demo_data create_server_config
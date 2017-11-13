#!/usr/bin/make

REGION = $(shell echo ${registry} | awk -F. '{print $$4}')
VERSION = $(shell echo `cat version_branch.txt`)

all: build test publish

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

create_client_db:
	@cd testing && docker build -t liveobs-testing:${VERSION} -f Dockerfile-testing . && cd ..
	docker-compose rm -f
	docker-compose build
	docker-compose -f docker-compose-initdb.yml build
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-initdb.yml up --abort-on-container-exit
	@docker rmi liveobs-testing:${VERSION}

get_sql_dump:
	mkdir -p db_dumps
	virtualenv venv
	venv/bin/pip install awscli && aws s3 cp "s3://liveobs-provisioning-eu-west-1/artifacts/odoo/dbs/${VERSION}/liveobs.sql" db_dumps/liveobs.sql
	@echo "FROM postgres:9.3\nADD ./liveobs.sql /docker-entrypoint-initdb.d/init.sql" > db_dumps/Dockerfile-postgres-load-dump
	rm -rf venv

run_server: login
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
	sleep 15
	VERSION=${VERSION} docker-compose \
		-f docker-compose.yml \
		-f docker-compose-liveobs-server.yml \
		-f docker-compose-unit-test.yml up web \
		| python testing/odoo_log_parsing.py

run_unit_tests_coverage:
	sed -i "s/__VERSION__/${VERSION}/" testing/Dockerfile-coverage
	@cd testing && docker build -t liveobs-coverage:${VERSION} -f Dockerfile-coverage . && cd ..
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
		| python testing/odoo_log_parsing.py

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

.PHONY: create_addons_dir clean login build test publish create_client_db run_unit_tests_coverage

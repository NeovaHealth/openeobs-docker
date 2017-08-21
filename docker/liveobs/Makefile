#!/usr/bin/make

REGION = $(shell echo ${registry} | awk -F. '{print $$4}')
VERSION = $(shell echo $${GO_PIPELINE_LABEL:-1}-$${GO_STAGE_COUNTER:-1})

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
	docker-compose -f docker-compose.yml -f docker-compose-initdb.yml up --abort-on-container-exit
	@docker rmi liveobs-testing:${VERSION}

get_sql_dump:
	mkdir -p db_dumps
	virtualenv venv
	venv/bin/pip install awscli && aws s3 cp "s3://liveobs-provisioning-eu-west-1/artifacts/odoo/dbs/${GO_DEPENDENCY_LABEL_LIVEOBS_DOCKER}/liveobs.sql" db_dumps/liveobs.sql
	@echo "FROM postgres:9.3\nADD ./liveobs.sql /docker-entrypoint-initdb.d/init.sql" > db_dumps/Dockerfile-postgres-load-dump
	rm -rf venv

install_sauce_connect:
	curl -o sauce_connect.tar.gz -SL https://saucelabs.com/downloads/sc-4.4.9-linux.tar.gz
	tar -xf sauce_connect.tar.gz
	rm sauce_connect.tar.gz
	mv sc-4.4.9-linux sauce_connect

run_sauce_connect:
	sauce_connect/bin/sc -u ${SAUCELABS_USERNAME} -k ${SAUCELABS_ACCESS_TOKEN} -l sauce_connect.log &

install_chrome_driver:
	curl -o chromedriver.zip -SL https://chromedriver.storage.googleapis.com/2.31/chromedriver_linux64.zip
	unzip -d chromedriver chromedriver.zip
	rm chromedriver.zip

run_server: login
	docker-compose rm -f
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml up -d db
	sleep 15
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml up -d --no-build web

run_unit_tests: login
	docker-compose rm -f
	VERSION=${VERSION} docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml build db
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml up -d db
	sleep 15
	docker-compose -f docker-compose.yml -f docker-compose-liveobs-server.yml -f docker-compose-unit-test.yml up web

test:
	@echo "FROM ${registry}/liveobs:${VERSION}\nCMD /bin/bash" > Dockerfile-rspec
	@docker build -t liveobs-rspec:${VERSION} -f Dockerfile-rspec .
	@bundle install
	@bundle exec rake spec
	@rm -rf vendor
	@docker rmi liveobs-rspec:${VERSION}

publish: login
	@echo -n "Checking for registry setting ... "
	@test -n "${registry}" || (echo "no registry setting" && exit 1)
	@echo OK
	@docker tag ${registry}/liveobs:${VERSION} ${registry}/liveobs:latest
	@docker push ${registry}/liveobs:${VERSION}
	@docker push ${registry}/liveobs:latest

.PHONY: create_addons_dir clean login build test publish create_client_db

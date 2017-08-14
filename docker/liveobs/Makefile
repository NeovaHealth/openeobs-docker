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

create_addons_dir:
	@mkdir -p liveobs_addons

build: clean login
	docker build --pull --no-cache -t ${registry}/liveobs:${VERSION} .
	docker tag ${registry}/liveobs:${VERSION} liveobs:${VERSION}
	@cd ..

create_client_db:
	@mkdir -p db_dumps
	docker-compose rm -f
	docker-compose build
	docker-compose -f docker-compose.yml -f docker-compose-initdb.yml up --abort-on-container-exit

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

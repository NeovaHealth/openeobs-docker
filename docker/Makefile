#!/usr/bin/make

all: build test publish
unit_test_on_gocd: stop_server clean get_sql_dump login run_unit_tests_coverage

create_addons_dir:
	make -C ${folder} $@

prebuild:
	make -C ${folder} $@

build:
	make -C ${folder} $@

test:
	make -C ${folder} $@

publish:
	make -C ${folder} $@

create_client_db:
	make -C ${folder} $@

login:
	make -C ${folder} $@

run_unit_tests:
	make -C ${folder} $@

run_unit_tests_coverage:
	make -C ${folder} $@

get_sql_dump:
	make -C ${folder} $@

run_server:
	make -C ${folder} $@

stop_server:
	make -C ${folder} $@

clean:
	make -C ${folder} $@

create_version_file:
	make -C ${folder} $@

.PHONY: create_addons_dir prebuild build test publish create_client_db run_unit_tests get_sql_dump clean run_server stop_server create_version_file

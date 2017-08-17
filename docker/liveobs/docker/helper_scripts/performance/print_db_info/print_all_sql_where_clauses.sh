#!/usr/bin/env bash
egrep -r -i -B 5 --color --exclude=*.js --exclude=*.pyc "WHERE\s+.*\s*(=|IN.*\()" /vagrant/data/nhclinical /vagrant/data/openeobs /vagrant/data/nh_configurations

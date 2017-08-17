#!/bin/bash

# Wrapper script to get AWS IP for hostname passed by jenkins job

#set -e
#set -o pipefail
#set -x

# Unset vars
unset nhcawsip
unset nhcawsid


# Handles failures
function failed() {
  echo -e "ERROR: Run failed"
  echo -e "$1"
  exit 1
}


function host2ip() {
	ADDRS=$(dig +short @${DNS} ${NHCHOST});
		if [ -z "$ADDRS" ]; then
			failed "DNS failure for ${NHCHOST}";
		fi
	aws_vars;
}

function aws_vars() {
	AWSIP=$ADDRS
	AWSID=`./ec2.py --host $AWSIP|grep ec2_id |cut -d '"' -f 4`
	jenkins_vars ${AWSIP} ${AWSID};
}

function jenkins_vars() {
	unset nhcawsip
	unset nhcawsid
	echo "ec2 ip = ${1}"
	echo "export nhcawsip=${1}" > nhcaws.out
	echo "ec2 id = ${2}"
	echo "export nhcawsid=${2}" >> nhcaws.out
#	exit 0
}

# Defaults
NHCHOST=$1
DNS=ns-1890.awsdns-44.co.uk

host2ip;

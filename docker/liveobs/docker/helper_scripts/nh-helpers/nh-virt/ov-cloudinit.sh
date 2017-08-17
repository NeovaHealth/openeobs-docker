#!/bin/bash
# Neova Health
# Script for creating oVirt virtual machines using REST API

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

# DO NOT INCLUDE OV_PASS IN THIS FILE
# export OV_PASS="<< yubikey >>"

# example usage for the brave
# robdyke@robdyke-X220:~/nh-virt$ echo y | ./ov-cloudinit.sh -c nh-ovirt-base-tmpl nh-rd-test10 172.16.87.110

#######################################################################################
# Script functions
# Handles usage of script
usage() {
	echo -e "Usage: $0\r
OPTIONS:\r
\t -t : Template only\r
\t -c : Template and create VM\r
PARAMS:\r
\t OV_TMPLNAME\r
\t OV_VMNAME\r
\t VM_NIC1_IP\r
EXAMPLE:\r
\t host:~/nh-virt$ echo y | ./ov-cloudinit.sh -c nh-ovirt-base-tmpl-01 nh-ovirt-base-test-01 172.16.87.101"
	exit 0
}

confirm() {
	#alert the user what they are about to do.
	echo "INFO: About to $1";
	#confirm with the user
	read -r -p "Are you sure? [Y/n] : " response
	case "$response" in
	    [yY][eE][sS]|[yY]) 
          #if yes, then execute the passed parameters
           $2 $3
           ;;
	    *)
          #Otherwise exit...
          echo "INFO: End"
          exit
          ;;
	esac
}

checkErrors() {
	# Function. Parameter 1 is the return code
	if [ "${1}" -ne "0" ]; then
		echo "ERROR: ${1} : ${2}"
		# as a bonus, make script exit with the right error code.
		exit ${1}
	fi
}

# Handles failures
failed() {
	echo -e "ERROR: Run failed"
	echo -e "$1"
	exit 1
}

templateXML() {
	echo "INFO: Creating XML definition for $OV_VMNAME"
	# Setup some vars
	export vm_ov_cluster=$OV_CLUSTER
	export vm_ov_tmplname=$OV_TMPLNAME
	export vm_name=$OV_VMNAME
	export vm_tld=neova.lan
	export vm_host=$OV_VMNAME
	export vm_nic1_name=eth0
	export vm_nic1_proto=DHCP
	#export vm_nic1_ip=$VM_NIC1_IP
	#export vm_nic1_mask=255.255.254.0
	#export vm_nic1_gway=172.16.86.11
	export vm_nic1_onboot=true
	export vm_dns_servers="192.168.1.100"
	export vm_dns_search=neova.lan
	export vm_root_pwd=neova1
	export vm_ssh_auth_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2kQH135aOKvCW6s8Ft6nPfzRqkKXW432a8A6GcCDNuv1cLwtVfWP+wk4oTDyXqKK9IGoIOQl0BoV+ZNGS/lm0zUZJPycOUyGRhBxGlB3qHzqkqOzxVTyELu01NMA3qppV4WK07cwW4UGDhtxtGKquPTbnTXgF5Z/rFAO46krqsijzRXXKdLnkcnO5XteEDpOA2J0XPRj8UshStcIY8Fegdh2zzoLvk7WsdpLmM7eBq7wkEkAgMdynfxe6tPr7Df350kCPhVYbc0LBKb9Ern7g6MaIvPlZSdV+Xb/ePEh+/iBhOY9MCvPLjTEHw36AI+u1iTh/I6HNgM4albuOBqVv Neova Health Insecure Public Key"
	export vm_ssh_regen_key=true
	env|grep vm_|j2 --format env ov_guest_tmpl.xml.j2 > $OV_DEFINITION
}

# Send the XML
sendXML() {
	curl -s -k -u $OV_USER:$OV_PASS -H "Content-type: application/xml" -X POST -T ${OV_DEFINITION} ${OV_URL}/vms > /dev/null 2>&1
	checkErrors $? "Sending XML to server failed"
	echo "INFO: Sent VM definition for $OV_VMNAME"
	rm -f ${OV_DEFINITION}
}

# Get the ID back
getID() {
	OV_ID=$(curl -s -k -u $OV_USER:$OV_PASS -H 'Content-type: application/xml' -X GET ${OV_URL}/vms?search=$OV_VMNAME|grep vm |grep id|cut -d'"' -f 4)
}

checkState() {
	echo "INFO: Waiting VM to finish creating"
	if [[ "$(curl -s -k -u $OV_USER:$OV_PASS -H "Accept: application/json" -X GET ${OV_URL}/vms/$OV_ID|../jq/jq --arg state down -c -e '.| select(.status.state|contains($state))' > /dev/null; echo $?)" -eq 0 ]]; then
		confirm "Start VM $OV_VMNAME" startVM $OV_ID
	else
		sleep 15s
		checkState
	fi
}

startVM() {
	if [[ $OV_VER == "3.5" ]]; then
	curl -s -k -u $OV_USER:$OV_PASS -H "Content-type: application/xml" --data '
<action>
<use_cloud_init>true</use_cloud_init>
</action>
' \
"${OV_URL}/vms/$1/start" > /dev/null
elif [[ $OV_VER == "3.4" ]]; then
	curl -s -k -u $OV_USER:$OV_PASS -H "Content-type: application/xml" --data '
<action/>
' \
"${OV_URL}/vms/$1/start" > /dev/null
fi
echo "INFO: Started $OV_VMNAME"
}

#######################################################################################
# Set up environment
# e.g. set VARs here

#OV_CLUSTER="CyberServ"
OV_CLUSTER="Default"
OV_URL="https://engine01.neova.lan/api"
#OV_URL="https://172.16.64.61/ovirt-engine/api"
OV_USER="admin@internal"
OV_VER="3.5"

#######################################################################################
# Handles options passed to script

while getopts “tcs” OPTION
do
    case $OPTION in
        t)
			ACTION="template"
			OV_TMPLNAME=$2
			OV_VMNAME=$3
			VM_NIC1_IP=$4
			OV_DEFINITION=$3.xml
			templateXML;
			;;
        c)
			ACTION="create"
			OV_TMPLNAME=$2
			OV_VMNAME=$3
			VM_NIC1_IP=$4
			OV_DEFINITION=$3.xml
			templateXML;
			sendXML;
			getID;
			checkState;
			;;
        s)
			ACTION="start"
			OV_VMNAME=$2
			getID;
			checkState;
			;;
        ?)
			usage
			;;
    esac
done

# If there isn't an action, show usage
if [[ -z $ACTION ]]
then
     usage
     exit 1
fi


#######################################################################################
# Done
cd ${ROOT_DIR}
echo -e "INFO: $SCRIPT_NAME completed successfully"
echo
exit 0
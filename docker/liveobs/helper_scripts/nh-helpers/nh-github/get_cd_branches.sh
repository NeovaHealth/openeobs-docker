#!/bin/bash
# Neova Health
# Checks all branches in NH GitHub repositories

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

#######################################################################################
# Script functions

# Handles usage of script
function usage() {
cat << EOF
Usage: $0 -o [list | csv | jenkins] -r [ openeobs | nhinternal ]

ENV VARS:
  - GH_TOKEN

EOF
}

# Handles failures
function failed() {
  echo -e "ERROR: Run failed"
  echo -e "$1"
  exit 1
}


# Check for branch
function check_branch() {

	if [[ -z $GH_TOKEN ]]
	then
	    failed "ERROR: Please set GH_TOKEN"
	fi

	for repo in ${GH_REPO}; do
		curl --silent -X GET -u ${GH_TOKEN}:x-oauth-basic "https://api.github.com/repos/${GH_ORG}/${repo}/branches" | ../jq/jq -c -e '.[] |{name: .name}'|cut -d'"' -f4 >> branches.out;
	done

}

function branch_list() {

	if [ $1 = "list" ]; then
		sort branches.out > branches.sorted;
		uniq branches.sorted > branches.uniq;
		cat branches.uniq > ${NH_REPO}_list.txt;
	fi

	if [ $1 = "csv" ] ; then
		sort branches.out > branches.sorted;
		uniq branches.sorted > branches.uniq;
		list=$(cat branches.uniq | tr '\n' ',')
		echo "$list" > ${NH_REPO}_list.csv
	fi

	if [ $1 = "jenkins" ] ; then
		sort branches.out > branches.sorted;
		uniq branches.sorted > branches.uniq;
		list=$(cat branches.uniq | tr '\n' ',')
		echo "branches=$list" > ${NH_REPO}_jenkins.csv
	fi

rm branches.out
rm branches.uniq
rm branches.sorted

}

# VARS
GH_ORG=NeovaHealth

#######################################################################################
# Handles options passed to script
# NOTE setting : after a switch variable means it requires some input

while getopts “r:o:” OPTION
do
    case $OPTION in
    	r)
			NH_REPO=$OPTARG
			;;
        o)
        	ACTION=$OPTARG
            ;;
        ?)
            usage
            exit 0
            ;;
    esac
done

if [[ -z $ACTION ]]; then
    usage;
    exit 1;
fi

if [ $NH_REPO = openeobs ] ; then
	GH_REPO="openeobs"
fi

if [ $NH_REPO = nhclinical ] ; then
	GH_REPO="nhclinical"
fi

if [ $NH_REPO = nhmobile ] ; then
	GH_REPO="nh-mobile"
fi

if [ $NH_REPO = qa ] ; then
	GH_REPO="openeobs-quality-assurance"
fi

if [ $NH_REPO = ansible ] ; then
	GH_REPO="nh-ansible"
fi

if [ $NH_REPO = playbooks ] ; then
	GH_REPO="nh-playbooks"
fi

if [ $NH_REPO = nhinternal ] ; then
	GH_REPO="nh-odoo_internal"
fi

if [ $ACTION = list ] ; then
    check_branch;
    branch_list $ACTION;
fi

if [ $ACTION = csv ] ; then
    check_branch;
    branch_list $ACTION;
fi

if [ $ACTION = jenkins ] ; then
    check_branch;
    branch_list $ACTION;
fi


#######################################################################################
# Done
cd ${ROOT_DIR}
echo -e ""
echo -e "DONE: Done."
echo -e ""
exit 0
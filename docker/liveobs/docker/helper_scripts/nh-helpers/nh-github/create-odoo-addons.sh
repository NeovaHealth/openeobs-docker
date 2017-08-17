#!/bin/bash
# Neova Health
# Creates odoo-addons.zip from GitHub repositories

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

#######################################################################################
# Script functions

# Handles usage of script
function usage() {
cat << EOF
Usage: $0 -r [ openeobs | nhinternal ] -b branch

OPTIONS:
  - r:  Create odoo-addons for repo
  - b:  Create odoo-addons for branch
  - c:  Clean up directory

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
validate_branch(){

	if [[ -z $GH_TOKEN ]]
	then
	    failed "ERROR: Please set GH_TOKEN"
	fi

	for repo in ${GH_REPO}; do
		echo -e "";
		echo -e "INFO: Checking for branch ${NH_BRANCH} in repo ${repo}";
		if [[ "$(curl --silent -X GET -u ${GH_TOKEN}:x-oauth-basic "https://api.github.com/repos/${GH_ORG}/${repo}/branches" | ../jq/jq --arg branch $NH_BRANCH -c -e '.[] | select(.name|contains($branch))' > /dev/null; echo $?)" -eq 0 ]]; then
			echo -e "INFO: Found ${NH_BRANCH} branch in repo ${repo}";
			GH_BRANCH=$NH_BRANCH;
			# Call fetch_archive
			fetch_archive ${repo} ${GH_BRANCH};
		elif [[ "$(curl --silent -X GET -u ${GH_TOKEN}:x-oauth-basic "https://api.github.com/repos/${GH_ORG}/${repo}/branches" | ../jq/jq --arg branch develop -c -e '.[] | select(.name|contains($branch))' > /dev/null; echo $?)" -eq 0 ]]; then
			echo -e "WARN: Branch ${NH_BRANCH} NOT FOUND in repo ${repo}";
			echo -e "INFO: Using branch develop for repo ${repo}";
			GH_BRANCH=develop;
			# Call fetch_archive
			fetch_archive ${repo} ${GH_BRANCH};
		else
			#[[ $(curl --silent -X GET -u ${GH_TOKEN}:x-oauth-basic "https://api.github.com/repos/${GH_ORG}/${repo}/branches" | ../jq/jq --arg branch master -c -e '.[] | select(.name|contains($branch))' > /dev/null; echo $1)" -eq 0 ]]; then
			echo -e "WARN: Branch ${NH_BRANCH} NOT FOUND in repo ${repo}";
			echo -e "INFO: Defaulting to branch master for repo ${repo}";
			GH_BRANCH=master;
			# Call fetch_archive
			fetch_archive ${repo} ${GH_BRANCH};
		fi;
	echo -e "DONE: Completed actions for branch ${GH_BRANCH} in repo ${repo}";
	echo -e "";
	done

	# Call create_odooaddons after fetch/extract for each repo
	create_odooaddons
}

# Fetch archive of repo/branch from github
fetch_archive(){
	echo -e "INFO: Fetching archive of branch ${2} from repo ${1}";
	curl --silent -o ${1}_${2}.${GH_FORMAT} -L -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/$GH_ORG/$1/zipball/$2;
	echo -e "DONE: Fetched archive of branch ${GH_BRANCH} from repo ${repo}";
	sleep 2
	sync
	# Calls extract_archive function
	extract_archive ${1} ${2}
}

# Extract archive of repo/branch
extract_archive() {
	echo -e "INFO: Extracting archive of branch ${2} from repo ${1}"
    local zip=${1}_${2}.${GH_FORMAT}
    local dest=${NH_OUTDIR:-.}
    local temp=$(mktemp -d) && unzip -q -d "$temp" "$zip" && mkdir -p "$dest" &&
    local f=("$temp"/*) &&
    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
        mv "$temp"/*/* "$dest"
    else
        mv "$temp"/* "$dest"
    fi && rm -rf "$temp"

	rm $zip
	echo -e "DONE: Extracted archive of branch ${2} from repo ${1}"

	create_manifest ${1} ${2}
}


create_manifest() {
# Create manifest.info
	echo -e "INFO: Create manifest.info for branch ${2} from repo ${1}"
	echo "-----------------------------" > ${ROOT_DIR}/${1}-${2}-manifest.info
	echo "NH odoo-addons" >> ${ROOT_DIR}/${1}-${2}-manifest.info
	echo "Built $NH_DT" >> ${ROOT_DIR}/${1}-${2}-manifest.info
	echo "Repo name ${1}" >> ${ROOT_DIR}/${1}-${2}-manifest.info
	echo "Git branch ${2}" >> ${ROOT_DIR}/${1}-${2}-manifest.info
	echo "-----------------------------" >> ${ROOT_DIR}/${1}-${2}-manifest.info
	curl --silent -X GET -u ${GH_TOKEN}:x-oauth-basic "https://api.github.com/repos/${GH_ORG}/${1}/branches/${2}" >> ${ROOT_DIR}/${1}-${2}-manifest.info
	mv ${ROOT_DIR}/${1}-${2}-manifest.info ${NH_OUTDIR}
	echo -e "INFO: Created manifest.info for branch ${2} from repo ${1}"
}

# Create odoo-addons.zip
create_odooaddons() {
	echo -e "INFO: Creating odoo-addons.zip"
	rm -f odoo-addons.zip
	cd ${NH_OUTDIR}
	for i in `ls -p | grep -v / | grep -v LICENSE|grep -v info`;do rm -rf $i; done
	cd ${ROOT_DIR}
	zip -q -r odoo-addons.zip ${NH_OUTDIR}
	echo -e "DONE: Created odoo-addons.zip"
	echo -e "INFO: Removing ${NH_OUTDIR} path"	
	rm -rf ${NH_OUTDIR}
}

# Removes odoo-addons.zip and path
clean_up() {
	cd ${ROOT_DIR}
	if [ -f ${NH_OUTDIR}.${GH_FORMAT} ] ; then
		echo -e "INFO: Removing ${NH_OUTDIR}.${GH_FORMAT}"
		rm -f ${NH_OUTDIR}.${GH_FORMAT}
	fi

	if [ -d ${NH_OUTDIR} ] ; then
		echo -e "INFO: Removing ${NH_OUTDIR} path"
		rm -rf ${NH_OUTDIR}
	fi
}

# VARS
GH_ORG=NeovaHealth
#GH_REPO='nhclinical openeobs patientflow'
GH_FORMAT=zip
NH_OUTDIR=odoo-addons
NH_DT=`date +"%d-%m-%Y %T"`

#######################################################################################
# Handles options passed to script
# NOTE setting : after a switch variable means it requires some input

while getopts “r:b:c” OPTION
do
    case $OPTION in
        r)
        	NH_REPO=$OPTARG
            ;;
        b)
        	NH_BRANCH=$OPTARG
        	ACTION=create
            ;;
        c)
        	ACTION=clean
            ;;
        ?)
            usage
            exit 0
            ;;
    esac
done

if [ $ACTION = clean ] ; then
    clean_up;
    exit 0;
fi

if [[ -z $NH_REPO ]] || [[ -z $NH_BRANCH ]]
then
    usage;
    exit 1;
fi

if [ $NH_REPO = openeobs ] ; then
	GH_REPO="nhclinical openeobs patientflow"
fi

if [ $NH_REPO = nhinternal ] ; then
	GH_REPO="nh-odoo_internal"
fi

if [ $ACTION = create ] ; then
	clean_up;
	validate_branch;
fi

#######################################################################################
# Done
cd ${ROOT_DIR}
echo -e ""
echo -e "DONE: Done."
echo -e ""
exit 0
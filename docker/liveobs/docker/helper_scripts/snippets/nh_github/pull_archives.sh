#!/bin/bash
# Neova Health
# Helper script to get archive.zip's from GitHub

# disallow using undefined variables
shopt -s -o nounset

set -e

# Script variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

# Detect proper usage
if [ "$#" -ne "1" ] ; then
	  echo -e "ERROR: Usage: $0 [ fetch / extract / makeaddons ]"
	  exit 1
fi

# Get archive
fetch_archive(){
	for element in ${GH_REPO}; do
		echo -e "INFO: Extracting archive for ${element}"
		echo "Getting archive for ${element}"
		#wget --header "Authorization: token $GH_TOKEN"  --output-document=$GH_REPO_$GH_RELEASE_$GH_BRANCH.$GH_FORMAT https://api.github.com/repos/$GH_ORG/$GH_REPO/zipball/$GH_BRANCH
		#curl -O -J -L -u $GH_TOKEN:x-oauth-basic $GH_BASE/$GH_ORG/$GH_REPO/$GH_RELEASE/$GH_BRANCH.$GH_FORMAT > $GH_REPO_$GH_RELEASE_$GH_BRANCH.$GH_FORMAT;
		curl -o ${element}_${GH_OUTFN} -L -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/$GH_ORG/$element/zipball/$GH_BRANCH;
	done
	echo "Done"
}

extract_archive() {
	for element in ${GH_REPO}; do
		echo -e "INFO: Extracting archive for ${element}"
	    local zip=${element}_$GH_OUTFN
	    local dest=${NH_OUTDIR:-.}
	    local temp=$(mktemp -d) && unzip -d "$temp" "$zip" && mkdir -p "$dest" &&
	    # shopt -s dotglob && local f=("$temp"/*) &&
	    local f=("$temp"/*) &&
	    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
	        mv "$temp"/*/* "$dest"
	    else
	        mv "$temp"/* "$dest"
	    fi && rm -rf "$temp"
	done
	echo -e "DONE: Extracting archive for ${element}"
}

create_odooaddons() {
	echo -e "INFO: Creating odoo-addons.zip"
	cd $NH_OUTDIR
	for i in `ls -p | grep -v / | grep -v LICENSE`;do rm -f $i; done
	cd $ROOT_DIR
	zip -r odoo-addons.zip odoo-addons/*
	for element in ${GH_REPO}; do
		rm -rf ${element}_$GH_OUTFN;
	done
	echo -e "INFO: FINISHED: Created odoo-addons.zip"
}

clean_all() {
	cd $ROOT_DIR
	echo -e "INFO: Removing .zip files"
	for i in `ls -p | grep zip`;do rm -f $i; done
	echo -e "INFO: Removing ${NH_OUTDIR} path"	
	rm -rf ${NH_OUTDIR};
}


# VARS
GH_BASE=https://github.com
GH_ORG=NeovaHealth
GH_REPO='nhclinical openeobs patientflow'
GH_RELEASE=archive
GH_BRANCH=develop
GH_FORMAT=zip
#GH_TOKEN=$1
GH_OUTFN=${GH_BRANCH}.${GH_FORMAT}
NH_OUTDIR=odoo-addons

# Call functions
if [ $1 = fetch ] ; then
	fetch_archive;
fi

if [ $1 = extract ] ; then
	fetch_archive;
	extract_archive;
fi

if [ $1 = makeaddons ] ; then
	fetch_archive;
	extract_archive;
	create_odooaddons;
fi

if [ $1 = clean ] ; then
	clean_all;
fi
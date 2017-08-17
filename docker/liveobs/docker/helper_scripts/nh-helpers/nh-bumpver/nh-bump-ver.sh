#!/bin/bash
# Neova Health nh-bump-ver.sh

# Simple script to create a file .version in the path the script is executed from
# Records Version number and date/time of the addition

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

#######################################################################################
# Script functions

# Handles usage of script
function usage() {
cat << EOF
Usage: $0 [ version ]

Requires version (e.g: v.1.2.3) to add to VERSION.md

EOF
}

# Handles failures
function failed() {
  echo -e "ERROR: Bump failed"
  echo -e "$1"
  exit 1
}

function ver_bump() {
    ver_file="${ROOT_DIR}/.version"
    ver_dt=`date +%d%m%y-%H%M`
    echo -e "Version $1 at $ver_dt" >> $ver_file
    exit 0
}

#######################################################################################
# Handles options passed to script

# Did the script get a version number as optargs?
if [ -z "$1" ] ; then
    failed "A version number is required"
else
    ver_bump $1;
fi

#######################################################################################
# Done
cd ${ROOT_DIR}
echo -e "INFO: Done."
echo
exit 0
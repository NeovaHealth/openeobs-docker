#!/bin/bash

# Neova Health
# Bash script template

# References
# confirm() - http://stackoverflow.com/questions/3231804/in-bash-how-to-add-are-you-sure-y-n-to-any-command-or-alias
# checkErrors() - http://steve-parker.org/sh/exitcodes.shtml

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

#######################################################################################
# Script functions

# Handles usage of script
usage() {
echo -e "Usage: $0\r
OPTIONS:\r
\t -v : Print version\r
\t -c : Run the confirm function\r
\t -f : Run the failed function\r
\t -e : Run the checkErrors function\r
\t -r : Requires an option"
exit 0
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
	echo -e "${1}"
	exit 1
}

confirm() {
	#alert the user what they are about to do.
	echo "INFO: About to $1";
	#confirm with the user
	read -r -p "Are you sure? [Y/n] : " response
	case "$response" in
	    ""|[yY][eE][sS]|[yY])
          #if yes, then execute the passed parameters
           $2 "${3}"
           ;;
	    *)
          #Otherwise exit...
          echo "INFO: End"
          exit
          ;;
	esac
}


#######################################################################################
# Set up environment
# e.g. set VARs here
SELF=(`id -u -n`)
VERSION=0.1.1

#######################################################################################
# This script illustrates usage of bash functions
echo "NEOVA HEALTH script template"
echo "INFO: Example Bash functions"

#######################################################################################
# Handles options passed to script
# NOTE setting : after a switch variable means it requires some input
# e.g. -s project name not required
# e.g. -r project name required
# When all options implemented getopts will be
# while getopts “sc:t:r:l:d:” OPTION

while getopts “vcfer:” OPTION
do
    case $OPTION in
        v)
            ACTION="version"
            ;;
        c)
			confirm "run the 'failed' function" failed "INFO: failed function called"
			;;
		f)
			failed "INFO: called the 'failed' function"
			;;
		e)
			ACTION="error"
			;;
		r)
			ACTION="required"
			ACTION_OPTION=$OPTARG
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
# Execute!
# e.g. call a function

if [ $ACTION = version ] ; then
    echo "INFO: Version is $VERSION";
fi

if [ $ACTION = required ] ; then
    echo "INFO: Supplied option was $ACTION_OPTION";
fi

if [ $ACTION = error ] ; then
    rm thisfile_notfound > /dev/null 2>&1
	checkErrors $? "error deleting nonexisting file"
fi


#######################################################################################
# Done
cd ${ROOT_DIR}
echo -e "INFO: Exit with code 0"
echo
exit 0
#!/bin/bash
# Script to dump remote NH Clinical database and save to local path
# Rob Dyke

set -e
set -o pipefail

# Set some vars
OUTPATH=/opt/backup
DTSTAMP=`date +%d%b%y-%H%M`
DBNAME=nhclinical
DBUSER=odoo
REMOTESVR=nhs-chadwell

# Print the vars
print_vars(){
	echo "The commands will use these vars"
	echo "Output path is:               $OUTPATH"
	echo "Datetime in filename will be: $DTSTAMP"
	echo "The output filename will be:  $OUTPATH/$DBNAME_$DTSTAMP.out"
	echo "The database to be dummped:   $DBNAME"
	echo "The database username is:     $DBUSER"
	echo "The remote server is:         $REMOTESVR"
}

print_cmds(){
echo "Dump from local server:"
echo "		pg_dump -U $DBUSER $DBNAME -F c -b -v -f $OUTPATH/$DBNAME_$DTSTAMP.out"

echo "Dump from remote to local over ssh"
echo "		ssh $REMOTESVR \"pg_dump -U $DBUSER $DBNAME -F c -b -v\" > $OUTPATH/$DBNAME_$DTSTAMP.out"
}


case "$1" in
        vars)
                print_vars
                ;;
        cmds)
                print_cmds
                ;;
        *)
            echo "Usage: $0 {vars|cmds}"
			echo "Use this script to help with pg_dump"
			echo "$0 vars - shows the vars as set"
			echo "$0 cmds - shows the cmds as set with vars"
esac
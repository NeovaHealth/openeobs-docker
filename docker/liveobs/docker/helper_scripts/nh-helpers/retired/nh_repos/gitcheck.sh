#!/bin/bash
# Neova Health
# Helper script to track a folder full of repos

set -ae

# Check for input params
if [ -z "$1" ]
	then
	echo "Usage: `basename $0` [all | reponame]"
	exit $E_NOARGS
fi

# Set repo prefix default
repoprfx=nh

# Set reponame from input params
reponame=$1

# Check status for all repos
repo_all(){
	echo "Checking all repos"
	for i in $(ls -1|grep nh); do gitstat=$(git -C $i status -sb); echo "Repo $i is $gitstat"; done
}

# Check status for a named repo
repo_named(){
	#echo "Checking repo $reponame"
	gitstat=$(git -C $reponame status -sb)
	echo "Repo $reponame is at $gitstat"
}

# List all repos
repo_list(){
	echo "Listing all repos with prefix $repoprfx"
	for i in $(ls -1|grep $repoprfx); do echo $i; done
}

case "$1" in 
        "all")
		repo_all
		;;
		"list")
		repo_list
		;;
		*)
		repo_named
		;;
esac
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

# Pull all repos
repo_all(){
	echo "Pulling all repos"
	for i in $(ls -1|grep nh); do gitstat=$(git -C $i status -sb); git -C $i pull; echo "Pulled $i is $gitstat"; done
}

# Pull a named repo
repo_named(){
	gitstat=$(git -C $reponame status -sb)
	git -C $reponame pull
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
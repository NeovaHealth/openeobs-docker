#!/bin/bash
# Neova Health
# Helper script to clone NH odoo-addons repos

set -ae

# Check for input params
if [ -z "$1" ]
	then
	echo "Usage: `basename $0` [all | list | name of repo ]"
	exit $E_NOARGS
fi

# Set some vars
repo_list=nh_odoo_addons.txt
repo_url=git.neovahealth.co.uk/r/nh_odoo
user=nh-anon
pass=nh-anon
repo_dir=/vagrant/odoo-addons

# Set reponame from input params
repo_name=$1

# Create output dir if not exist
mkdir -p $repo_dir

# Pull all repos
repo_all(){
	echo "Pulling all repos"
	for i in $(cat $repo_list);
		do git clone https://$user:$pass@$repo_url/$i.git $repo_dir/$i;
	done
}

# Pull a named repo
repo_named(){
	echo "Pulling $repo_name"
	git clone https://$user:$pass@$repo_url/$repo_name.git $repo_dir/$i
}

# List all repos
repo_list(){
	echo "Listing all repos for dry-run"
	for i in $(cat $repo_list);
		do echo "Would have cloned https://$user:$pass@$repo_url/$i.git to $repo_dir/$i";
	done
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
#!/bin/bash
set -e
# Neova Health

# Gets branches from all nh_odoo repos, returns a combined list of branches

# Some vars
repo_out=nh_odoo_addons
repo_list=nh_odoo_addons.txt
repo_url=https://git.neovahealth.co.uk/r/nh_odoo
repo_fb=$1
repo_dev=develop

# Init output repo
git init $repo_out

for i in $(cat $repo_list);
	do cd $repo_out;
	if git ls-remote --exit-code -h $repo_url/$i.git $repo_fb &>/dev/null -eq 2
		then
                        echo "Adding branch $repo_fb from remote repo $i"
                        git remote add -t $repo_fb -f $i $repo_url/$i.git
		else
			echo "Adding branch $repo_dev from remote repo $i"
			git remote add -t $repo_dev -f $i $repo_url/$i.git
	fi;
	cd ../;
done

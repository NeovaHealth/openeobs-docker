#!/bin/bash
set -e
# Neova Health

# Gets branches from all nh_odoo repos, returns a combined list of branches

# Some vars
repo_list=nh_odoo_repos.txt
repo_url=https://git.neovahealth.co.uk/r/nh_odoo
repo_fb=$1

for i in $(cat $repo_list);
	do if git ls-remote --exit-code --quiet -h $repo_url/$i.git $repo_fb &>/dev/null -eq 2
		then
			echo "Branch $repo_fb FOUND"
		else
			echo "Branch $repo_fb NOT FOUND" >&2
	fi;
done

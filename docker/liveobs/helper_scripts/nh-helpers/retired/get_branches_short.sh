#!/bin/bash
# Neova Health

# Gets branches from all nh_odoo repos, returns a combined list of branches

# Some vars
repo_list=nh_odoo_repos.txt
repo_url=https://git.neovahealth.co.uk/r/nh_odoo

for i in $(cat $repo_list);
	do git ls-remote -h $repo_url/$i.git|cut -d "/" -f3 >> branches.out;
	sort branches.out > branches.sorted;
	uniq branches.sorted > nh_odoo_branches.txt;
done

rm branches.out
rm branches.sorted

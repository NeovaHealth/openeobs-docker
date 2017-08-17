#!/bin/bash
# Neova Health

# Gets branches from all nh_odoo repos, returns a combined list of branches

# Some vars
repo_list=nh_odoo_repos.txt
repo_url=git.neovahealth.co.uk/r/nh_odoo
user=nh-anon
pass=nh-anon

# Check for input params
if [ -z "$1" ]
	then
	echo "Usage: `basename $0` [list | csv]"
	exit $E_NOARGS
fi

if [ $1 = "list" ]; then
for i in $(cat $repo_list);
	do git ls-remote -h https://$user:$pass@$repo_url/$i.git|cut -d "/" -f3 >> branches.out;
	sort branches.out > branches.sorted;
	uniq branches.sorted > nh_odoo_branches.txt;
done
fi

if [ $1 = "csv" ] ; then
for i in $(cat $repo_list);
	do git ls-remote -h https://$user:$pass@$repo_url/$i.git|cut -d "/" -f3 >> branches.out;
	sort branches.out > branches.sorted;
	uniq branches.sorted > nh_odoo_branches.txt;
	list=$(cat nh_odoo_branches.txt | tr '\n' ',')
	echo "$list" > nh_odoo_branches.csv
done
fi

if [ $1 = "jenkins" ] ; then
for i in $(cat $repo_list);
	do git ls-remote -h https://$user:$pass@$repo_url/$i.git|cut -d "/" -f3 >> branches.out;
	sort branches.out > branches.sorted;
	uniq branches.sorted > nh_odoo_branches.txt;
	list=$(cat nh_odoo_branches.txt | tr '\n' ',')
	echo "branches=$list" > nh_odoo_branches_jenkins.csv
	rm nh_odoo_branches.txt
done
fi

rm branches.out
rm branches.sorted

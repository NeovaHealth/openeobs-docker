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
cd $repo_out
echo "Merge branch for $repo_fb" > merge-branch-info.txt
echo "" > .gitignore
git add merge-branch-info.txt
git add .gitignore
git commit -m "merge-branch-info.txt"
cd ../

# Add remotes
for i in $(cat $repo_list);
	do cd $repo_out;
                        git remote add $i $repo_url/$i.git
	cd ../;
done


for i in $(cat $repo_list);
        do cd $repo_out;
        if git ls-remote --exit-code -h $repo_url/$i.git $repo_fb -eq 2
                then
                        echo "Adding branch $repo_fb from remote repo $i"
			echo "${i}_${repo_fb}" >> ../$repo_fb.out
                else
                        echo "Adding branch $repo_dev from remote repo $i"
			echo "${i}_${repo_dev}" >> ../$repo_dev.out
                fi;
        cd ../;
done

cd $repo_out
git checkout master
cd ../

for i in $(cat $repo_dev.out);
do cd $repo_out;
	git merge -Xours -m "merge $i" $i;
	cd ../;
done

for i in $(cat $repo_fb.out);
do cd $repo_out;
        git merge -Xours -m "merge $i" $i;
        cd ../;
done

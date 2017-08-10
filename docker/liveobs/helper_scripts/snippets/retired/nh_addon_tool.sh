#!/bin/bash

# Neova Health
# Helper script to clone nh_odoo git repos
# Creates .tar.gz output

# Declare some vars
destdir=nhc-repos
addonsdir=odoo-addons
builddt=`date +%d%m%y-%H%M`
jbuild=$4

# GIT Repo info, can be passed on command line
gitbranch=$1
gituser=$2
gitpass=$3
giturl="https://$gituser:$gitpass@git.neovahealth.co.uk/r/nh_odoo"

# nh_odoo repos
nhrepos="nh_clinical_core nh_configurations nh_core nh_eobs nh_eobs_mobile nh_graphs nh_observations nh_patient_flow nh_report_printing"

# Cleanup and recreate destination paths
rm -rf $destdir
mkdir -p $destdir

# Create manifest.txt
echo "-----------------------------" > $destdir/manifest.txt
echo "NHC odoo-adons               " >> $destdir/manifest.txt
echo "Built $builddt               " >> $destdir/manifest.txt
echo "Git branch $gitbranch        " >> $destdir/manifest.txt
echo "-----------------------------" >> $destdir/manifest.txt

# Get the repos, switch branch, get the rev hash and update the manifest.txt
echo "Cloning NH Repos"
for i in $nhrepos; do
	git clone $giturl/$i.git $destdir/$i --recursive;
	cd $destdir/$i
	git checkout $gitbranch
	nh_br_status=`git status |head -1|cut -d" " -f3`
	nh_br_hash=`git rev-parse --short HEAD`
	git archive --format=zip -o ../odoo-addons.zip HEAD
	echo "Repo $i from $nh_br_status at $nh_br_hash" >> ../manifest.txt
	cd ../../
	done
echo "Done"

# Cleanup and recreate addons path
# rm -rf $addonsdir
# mkdir -p $addonsdir

# Get in working dir
cd $addonsdir

# Get the manifest from the repos we cloned before
cp ../$destdir/manifest.txt .

# Expand the git .zip archives
for i in `ls -1 ../$destdir/*.zip`; do unzip $i; done
cd ../

# Make nhclinical addons archive
tar -czvf nhc-odoo-addons-$jbuild.tar.gz $addonsdir

# Clean up after dirs
rm -rf $destdir
rm -rf $addonsdir

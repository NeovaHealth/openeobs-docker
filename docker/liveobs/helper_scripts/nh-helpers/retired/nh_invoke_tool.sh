#!/bin/bash

# Neova Health
# Helper script to clone nhc_invoke git repo
# Creates .tar.gz output

# Declare some vars
builddt=`date +%d%m%y-%H%M`
jbuild=$4

# GIT Repo info, can be passed on command line
gitbranch=$1
gituser=$2
gitpass=$3

# Declare vars for invoke
invrepo="nhc_invoke"
invrepourl="https://$gituser:$gitpass@git.neovahealth.co.uk/r/t4clinical"
invgitdest=nhc-inv
invdir=nhc_invoke

# Cleanup and recreate destination paths
rm -rf $invgitdest
mkdir -p $invgitdest

# Create manifest.txt
mkdir -p $invgitdest
echo "-----------------------------" > $invgitdest/manifest.txt
echo "NHC Invoke Tool              " >> $invgitdest/manifest.txt
echo "Built $builddt               " >> $invgitdest/manifest.txt
echo "Git branch $gitbranch        " >> $invgitdest/manifest.txt
echo "-----------------------------" >> $invgitdest/manifest.txt

# Get nhc_invoke repo
git clone $invrepourl/$invrepo.git $invgitdest/$invrepo --recursive;
cd $invgitdest/$invrepo
git checkout $gitbranch
nh_br_status=`git status |head -1|cut -d" " -f3`
nh_br_hash=`git rev-parse --short HEAD`
git archive --format=zip -o ../$invrepo-$nh_br_hash.zip HEAD
echo "Repo $invrepo from $nh_br_status at $nh_br_hash" >> ../manifest.txt
cd ../../

# Cleanup and recreate nhc_invoke path
rm -rf $invdir
mkdir -p $invdir

# Get in working dir
cd $invdir

# Get the manifest from the repos we cloned before
cp ../$invgitdest/manifest.txt .

# Expand the git .zip archives
for i in `ls -1 ../$invgitdest/*.zip`; do unzip $i; done
cd ../

# Make nhclinical addons archive
tar -czvf nhc-invoke-$jbuild.tar.gz $invdir

# Clean up after dirs
rm -rf $invgitdest
rm -rf $invdir

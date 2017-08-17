#!/usr/bin/env bash

# Neova Health
# Helper script to clone all the nh-tooling repos

##################################################################
# Declare some vars
NHSELF=`pwd` # assumes working directory is where you want the repos
NHURL=github.com
NHPATH=NeovaHealth

# Neova Health repos
NHREPO="nh-vagrant nh-helpers nh-ansible nh-vmbuilder nh-playbooks"
GITVER=`git --version`
BRANCH=master
##################################################################
# Functions

# Fail if git version is 1.7.x
# Require =< 1.8.x for credentials and -C option
function check_gitver() {
	if [[ $(echo $GITVER |cut -d' ' -f3|grep 1.7 > /dev/null 2>&1; echo $?) -ne 1 ]]; then
			echo "FAIL: Your ${GITVER} is too old" >&2
			echo "FAIL: Get a newer version of git > 1.7" >&2
			exit 1
	fi
	clone_tooling
}

# Clone nh-tooling repos
function clone_tooling() {

	# Silently enabling git credentials
	# Trust me, you'll thank me in the long run
	# -- Rob
	git config --global credential.helper cache

	echo ""
	echo "INFO: Fetching nh-tooling repos"

	for i in $NHREPO; do
		if [[ ! -d $NHSELF/$i ]]; then
		echo ""
		echo "INFO: Cloning ${i}";
		git clone -q https://$NHURL/$NHPATH/$i.git $NHSELF/$i -b $BRANCH;
			if [[ -f $NHSELF/$i/.gitmodules ]]; then
				git -C $i submodule --quiet update --init > /dev/null 2>&1;
					if [ ! $? -eq 0 ]; then
  						echo "WARN: Unable to update submodules for ${i}" >&2
  					else
  						echo "INFO: Updated submodules for ${i}";
					fi
			fi
		else
			echo "FAIL: Unable to clone ${i}, path exists";
		fi
	done
}

if [ $# = 1 ]; then
    echo "You selected $1 as default branch"
    BRANCH=$1
fi
check_gitver

##################################################################
echo ""
echo "INFO: Done"
exit 0

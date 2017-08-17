#!/bin/bash

# Neova Health
# Helper script to install prep for VM building
# Install packer, vagrant and virtualbox

# VARS
PURL=https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip
PHOME=/opt/packer
VURL=https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4_x86_64.deb
ARCH=deb

echo "Running NH build toolchain setup"

# Get Packer.io
install_packer(){
	echo "Installing packer.io from $PURL"
	wget --show-progress -q -O /tmp/packer.zip $PURL
	sudo mkdir -p $PHOME
	sudo unzip /tmp/packer.zip -d $PHOME
	sudo rm /tmp/packer.zip
	echo "Setting environment variables"
	echo "# PATH for packer.io" >> ~/.profile
	echo "PHOME=$PHOME" >> ~/.profile
	echo 'export PATH="$PATH:$PHOME"' >> ~/.profile
	echo "Done"
}

# Get VagrantUp
install_vagrant(){
	echo "Installing Vagrant from $VURL"
	wget --show-progress -q -O /tmp/vagrant.deb $VURL
	sudo dpkg -i /tmp/vagrant.deb
	sudo rm /tmp/vagrant.deb
	echo "Done"
}

# Install Virtualbox
install_vbox(){
	echo "Installing Virtual Box from default repos"
	sudo apt-get install -y virtualbox virtualbox-guest-additions-iso virtualbox-guest-dkms virtualbox-guest-source
	echo "Done"
}

# Install Ansible
install_ansible(){
	echo "Installing Ansible from PPA"
	sudo apt-get -y install software-properties-common
	sudo apt-add-repository -y ppa:ansible/ansible
	sudo apt-get -y update
	sudo apt-get -y install ansible
	echo "Done"
}

case "$1" in
        packer)
			install_packer
			;;
        vagrant)
			install_vagrant
			;;
        vbox)
			install_vbox
			;;
        ansible)
			install_ansible
			;;
		all)
			install_packer
			install_vagrant
			install_vbox
			install_ansible
			;;
       *)
	        echo "Usage: $0 {packer|vagrant|vbox|ansible|all}"
			echo "Use this shell script to install and setup a build toolchain."
			echo "Set defaults in script header."
esac
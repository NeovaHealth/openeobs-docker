#!/bin/bash

# Neova Health
# Helper script to setup NH yum repos and then cleanup an ovirt guest prior to making template

# Install necessary tools
echo "Installing tools"
{
	yum update -y
	yum install -y wget openssh-clients vim nmap ovirt-guest-agent tmux cloud-init zip unzip git ansible
} &> /dev/null

# Clean up everything!
# Rules, leases, logs, history, etc

# Clean network configuration
echo "Cleaning network scripts"
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/^UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/^IPV6INIT/d" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/^DHCP/d" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/^NM_CONTROLLED/d" /etc/sysconfig/network-scripts/ifcfg-eth0
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

# Remove udev file to be re-generated on boot
echo "Removing udev files"
{
	shred -uv /etc/udev/rules.d/70-persistent-net.rules
} &> /dev/null

# Clear out any existing dhcp leases
echo "Shreding dhcp"
{
	shred -uv /var/lib/dhclient/*
} &> /dev/null

# Clean up any package caches
echo "Cleaning up yum"
{
	yum clean all
} &> /dev/null

# zero out /etc/resolv.conf (re-created on boot)
echo "Removing resolv.conf"
{
	rm -f /etc/resolv.conf
} &> /dev/null

# clear out tmp files
echo "Cleaning out /tmp"
{
	pushd /tmp
	shred -uv /tmp/*
	popd
} &> /dev/null

# clear out log files
echo "Cleaning out log files"
{
	pushd /var/log
	shred -uv wtmp cron dmesg* lastlog secure messages maillog
	popd
} &> /dev/null

# force re-creation of random-seed
echo "Removing random-seed"
{
	pushd /var/lib
	shred -uv ./random-seed
	popd
} &> /dev/null

# Save the build and cleanup date / time
echo "Saving Date/Time of cleanup"
build_dt=`date`
{
	cat <<-REPO > box_build_timestamp.txt
# Neova Health
# Built and cleaned using helper script to cleanup an ovirt guest prior to making template
# VM built and cleaned on $build_dt
	REPO
mv box_build_timestamp.txt /etc/box_build_timestamp.txt
} &> /dev/null

# Zero disk to make a compressed guest template
echo "About to zero out disk"
echo "Remember to run the following commands after zeroing out the disk"
echo ""
echo "sync"
echo "rm -rf /empty.out"
echo "history -c"
echo ""

# Zero out the rest of the free space using dd, then delete the written file.
echo "Now zeroing the disk"
{
	dd if=/dev/zero of=/empty.out bs=10M
} &> /dev/null
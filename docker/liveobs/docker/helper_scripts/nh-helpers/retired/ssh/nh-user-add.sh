#!/bin/bash

# Helper script to setup a user on client machines with an SSH key in authorized_keys

set -e
set -o pipefail
set -x

# Defaults
USER=$1

#Create Account
useradd -c $USER -m $USER -p "$(openssl passwd -1)" -s /bin/bash

# sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USER
echo "Defaults:$USER env_keep += SSH_AUTH_SOCK" >> /etc/sudoers.d/$USER
chmod 0440 /etc/sudoers.d/$USER
sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers

if [ $2 = "secure" ]; then
# SSH Keygen on host
mkdir -p /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
ssh-keygen -t rsa -b 4096 -C "$USER@nhtek.io" -f /home/$USER/.ssh/nh-$USER.rsa -N ''
chmod 600 /home/$USER/.ssh/nh-$USER.rsa
chmod 640 /home/$USER/.ssh/nh-$USER.rsa.pub
fi

if [ $2 = "insecure" ]; then
# Slipstream insecure NH SSH Key
mkdir -p /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh 
cat <<-KEY > /home/$USER/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2kQH135aOKvCW6s8Ft6nPfzRqkKXW432a8A6GcCDNuv1cLwtVfWP+wk4oTDyXqKK9IGoIOQl0BoV+ZNGS/lm0zUZJPycOUyGRhBxGlB3qHzqkqOzxVTyELu01NMA3qppV4WK07cwW4UGDhtxtGKquPTbnTXgF5Z/rFAO46krqsijzRXXKdLnkcnO5XteEDpOA2J0XPRj8UshStcIY8Fegdh2zzoLvk7WsdpLmM7eBq7wkEkAgMdynfxe6tPr7Df350kCPhVYbc0LBKb9Ern7g6MaIvPlZSdV+Xb/ePEh+/iBhOY9MCvPLjTEHw36AI+u1iTh/I6HNgM4albuOBqVv Neova Health Insecure Public Key
KEY
chown $USER:$USER /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/authorized_keys
fi


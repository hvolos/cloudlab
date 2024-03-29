#!/bin/bash

# Adapted from https://github.com/cstlee/cloudlab-profile

USERS="root `ls /users`"

# Install packages
echo "Installing common utilities"
apt-get update
apt-get -yq install ccache htop mosh vim tmux pdsh tree axel

echo "Installing performance tools"
kernel_release=`uname -r`
apt-get -yq install linux-tools-common linux-tools-${kernel_release} \
        hugepages cpuset msr-tools i7z numactl tuned
        
# Setup password-less ssh between nodes
for user in $USERS; do
    if [ "$user" = "root" ]; then
        ssh_dir=/root/.ssh
    else
        ssh_dir=/users/$user/.ssh
    fi
    /usr/bin/geni-get key > $ssh_dir/id_rsa
    chmod 600 $ssh_dir/id_rsa
    chown $user: $ssh_dir/id_rsa
    ssh-keygen -y -f $ssh_dir/id_rsa > $ssh_dir/id_rsa.pub
    cat $ssh_dir/id_rsa.pub >> $ssh_dir/authorized_keys2
    chmod 644 $ssh_dir/authorized_keys2
    cat >>$ssh_dir/config <<EOL
    Host *
         StrictHostKeyChecking no
EOL
    chmod 644 $ssh_dir/config
done

# Change user login shell to Bash
for user in `ls /users`; do
    chsh -s `which bash` $user
done

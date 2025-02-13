#!/bin/bash

DISK="/dev/sdb"


parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary ext4 1MiB 201MiB
parted -s $DISK mkpart primary ext4 201MiB 50GiB
parted -s $DISK mkpart primary linux-swap 50GiB 60GiB

mkfs.ext4 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkswap /dev/sdb3
mkdir -v /mnt/lfs


export LFS=/mnt/lfs
sudo mount -v -t ext4 /dev/sdb2 $LFS
sudo mkdir -v /mnt/lfs/boot
sudo mount -v -t ext4 /dev/sdb1 $LFS/boot
sudo swapon -v /dev/sdb3

sudo mkdir -v $LFS/sources
sudo chmod -v a+wt $LFS/sources

wget --input-file="https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv" --continue --directory-prefix=$LFS/sources
cd $LFS/sources
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
sudo chown root:root $LFS/sources/*


bash /vagrant/scripts/setup_directory.sh
cd $LFS

mkdir /tools
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo "lfs:lfs" | chpasswd
sudo bash /vagrant/scripts/grant_access.sh
chown -R lfs:lfs /mnt/lfs/

echo "Enter the following command to switch to the lfs user: su - lfs"

#bash /vagrant/scripts/install_packages.sh
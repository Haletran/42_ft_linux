#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
DISK="/dev/sdb"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit
fi

if [ -f /tmp/tool ]; then
    bash reset_lfs.sh
fi

echo -e "${YELLOW}Creating disk partitions...${NC}"
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary ext4 1MiB 201MiB
parted -s $DISK mkpart primary ext4 201MiB 40GiB
parted -s $DISK mkpart primary linux-swap 40GiB 50GiB

echo -e "${YELLOW}Formatting partitions...${NC}"
mkfs.ext4 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkswap /dev/sdb3

if [ ! -d /mnt/lfs ]; then
    mkdir -v /mnt/lfs
fi

export LFS=/mnt/lfs
echo -e "${YELLOW}Mounting filesystems...${NC}"
sudo mount -v -t ext4 /dev/sdb2 $LFS
sudo mkdir -v /mnt/lfs/boot
sudo mount -v -t ext4 /dev/sdb1 $LFS/boot
sudo swapon -v /dev/sdb3

echo -e "${YELLOW}Setting up source directory...${NC}"
sudo mkdir -v $LFS/sources
sudo chmod -v a+wt $LFS/sources

if [ ! -f /mnt/lfs/sources/wget-list ]; then
    echo -e "${YELLOW}Downloading source files...${NC}"
    wget --input-file="https://www.fr.linuxfromscratch.org/view/lfs-8.2-fr/wget-list" --continue --directory-prefix=$LFS/sources
    cd $LFS/sources
    wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
fi

sudo chown root:root $LFS/sources/*

echo -e "${YELLOW}Verifying downloads...${NC}"
pushd $LFS/sources
md5sum -c md5sums
popd

cd -
bash setup_directory.sh
cd $LFS

echo -e "${YELLOW}Setting up tools directory and user...${NC}"
mkdir -v $LFS/tools
ln -sv $LFS/tools /
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo "lfs:lfs" | chpasswd

mkdir -v $LFS/scripts
cd $LFS/scripts
git clone https://github.com/Haletran/42_ft_linux.git
cd -
sudo bash grant_access.sh
chown -R lfs:lfs /mnt/lfs/
chown -v lfs $LFS/tools
chown -v lfs $LFS/sources
chown -v lfs $LFS/scripts

echo -e "${GREEN}Enter the following command to switch to the lfs user:${NC} ${YELLOW}su - lfs${NC}"

# 42_ft_linux
 Build a basic, but functional, linux distribution using LFS book


## REQUIREMENTS

- [ ] Use a kernel version 4.x. Stable or not, as long as it’s a 4.x version
- [ ] Kernel sources must be in /usr/src/kernel-$(version)
- [ ] 3 differents partitions or more (root, /boot and a swap partition)
- [ ] Implement a kernel_module loader, like udev.
- [ ] The kernel version must contain your student login : `kernel 4.1.2-<student_login>`
- [ ] The distribution hostname must be your student login
- [ ] 32 or 64-bit system
- [ ] Use central management and configuration, like SysV or SystemD
- [ ] Boot with a bootloader, like LILO or GRUB.
- [ ] Your kernel binary located in /boot must be named like this: `vmlinuz-<linux_version>-<student_login>`
- [ ] Install the following packages:

<details>

| Package | Version |
|---------|---------|
| Acl | 2.2.52 |
| Attr | 2.4.47 |
| Autoconf | 2.69 |
| Automake | 1.15 |
| Bash | 4.3.30 |
| Bc | 1.06.95 |
| Binutils | 2.25.1 |
| Bison | 3.0.4 |
| Bzip2 | 1.0.6 |
| Check | 0.10.0 |
| Coreutils | 8.24 |
| DejaGNU | 1.5.3 |
| Diffutils | 3.3 |
| Eudev | 3.1.2 |
| E2fsprogs | 1.42.13 |
| Expat | 2.1.0 |
| Expect | 5.45 |
| File | 5.24 |
| Findutils | 4.4.2 |
| Flex | 2.5.39 |
| Gawk | 4.1.3 |
| GCC | 5.2.0 |
| GDBM | 1.11 |
| Gettext | 0.19.5.1 |
| Glibc | 2.22 |
| GMP | 6.0.0a |
| Gperf | 3.0.4 |
| Grep | 2.21 |
| Groff | 1.22.3 |
| GRUB | 2.02 beta2 |
| Gzip | 1.6 |
| Iana-Etc | 2.30 |
| Inetutils | 1.9.4 |
| Intltool | 0.51.0 |
| IPRoute2 | 4.2.0 |
| Kbd | 2.0.3 |
| Kmod | 21 |
| Less | 458 |
| Libcap | 2.24 |
| Libpipeline | 1.4.1 |
| Libtool | 2.4.6 |
| M4 | 1.4.17 |
| Make | 4.1 |
| Man-DB | 2.7.2 |
| Man-pages | 4.02 |
| MPC | 1.0.3 |
| MPFR | 3.1.3 |
| Ncurses | 6.0 |
| Patch | 2.7.5 |
| Perl | 5.22.0 |
| Pkg-config | 0.28 |
| Procps | 3.3.11 |
| Psmisc | 22.21 |
| Readline | 6.3 |
| Sed | 4.2.2 |
| Shadow | 4.2.1 |
| Sysklogd | 1.5.1 |
| Sysvinit | 2.88dsf |
| Tar | 1.28 |
| Tcl | 8.6.4 |
| Texinfo | 6.0 |
| Time Zone Data | 2015f |
| Udev-lfs Tarball | udev-lfs-20140408 |
| Util-linux | 2.27 |
| Vim | 7.4 |
| XML::Parser | 2.44 |
| Xz Utils | 5.2.1 |
| Zlib | 1.2.8 |

</details>

## INFOS

I'm using `vagrant` to create a VM that will be used to build the LFS system. So it will be easier if i do something wrong to restart from scratch.

```bash
# create a new VM
vagrant up
# connect to the VM
vagrant ssh
# stop the VM
vagrant halt
# delete the VM
vagrant destroy -f
```

## STEPS


```bash
# create the partitions
sudo parted /dev/sdb
## /boot 200M
## / 50G
## swap 10G
mklabel gpt
mkpart primary ext4 1MiB 201MiB
mkpart primary ext4 201MiB 50GiB
mkpart primary linux-swap 50GiB 60GiB

# format the partitions
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.ext4 /dev/sdb2
# create a swap partition
sudo mkswap /dev/sdb3

# setup the $LFS variable
sudo mkdir -v /mnt/lfs
export LFS=/mnt/lfs
# mount the partitions
sudo mount -v -t ext4 /dev/sdb2 $LFS
sudo mkdir -v /mnt/lfs/boot
sudo mount -v -t ext4 /dev/sdb1 $LFS/boot
sudo swapon -v /dev/sdb3

sudo systemctl daemon-reload

## PART 3

#  create sources 
sudo mkdir -v $LFS/sources
sudo chmod -v a+wt $LFS/sources

# download the list of packages
wget --input-file="https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv" --continue --directory-prefix=$LFS/sources
# download the packages
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
# make the packages owned by root
sudo chown root:root $LFS/sources/*
# might need to add patches to some packages https://www.linuxfromscratch.org/lfs/view/stable/chapter03/patches.html


## PART 4

# create the tools directory
sudo bash /vagrant/scripts/setup_directory.sh
sudo mkdir -pv $LFS/tools
# add the lfs user
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
sudo passwd lfs
#sudo usermod -a -G sudo lfs

sudo bash /vagrant/scripts/grant_access.sh
#sudo chown -R lfs:lfs /mnt/lfs/tools

# login as lfs
su - lfs

# setup the environment

#create the bash_profile file
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
# create the bashrc file
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF

# reload the bash_profile
source ~/.bash_profile

## PART 5 - Compiling Cross-Toolchain

tar -xvf $LFS/sources/binutils-2.43.1.tar.xz
cd binutils-2.43.1 && mkdir -v build && cd build

# prepare Binutils for compilation: 
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

# Compile and install the package
make
make install

cd ../.. && rm -rf binutils-2.43.1
tar -xvf $LFS/sources/gcc-14.2.0.tar.xz && cd gcc-14.2.0

# prepare GCC for compilation
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

# set the default directory for 64-bit libraries
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac


# create a build directory
mkdir -v build && cd build

../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.40 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

make
make install


cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h


tar -xvf linux-6.10.5.tar.xz && cd linux-6.10.5
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr


# attention could destroy the VM if not done correctly
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac

```

## RESSOURCE

- [LFS book](https://www.linuxfromscratch.org/lfs/view/stable/index.html)
- [ChrisTitusTech LFS video](https://www.youtube.com/watch?v=oV541sgHKGo)

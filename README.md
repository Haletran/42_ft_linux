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

### PARTITIONS 

> /boot – Highly recommended. Use this partition to store kernels and other booting information. To minimize potential boot problems with larger disks, make this the first physical partition on your first disk drive. A partition size of 200 megabytes is adequate. 

> A root LFS partition (not to be confused with the /root directory) of twenty gigabytes is a good compromise for most systems. It provides enough space to build LFS and most of BLFS, but is small enough so that multiple partitions can be easily created for experimentation. 

>  Most distributions automatically create a swap partition. Generally the recommended size of the swap partition is about twice the amount of physical RAM, however this is rarely needed. If disk space is limited, hold the swap partition to two gigabytes and monitor the amount of disk swapping.If you want to use the hibernation feature (suspend-to-disk) of Linux, it writes out the contents of RAM to the swap partition before turning off the machine. In this case the size of the swap partition should be at least as large as the system's installed RAM.Swapping is never good. For mechanical hard drives you can generally tell if a system is swapping by just listening to disk activity and observing how the system reacts to commands. With an SSD you will not be able to hear swapping, but you can tell how much swap space is being used by running the top or free programs. Use of an SSD for a swap partition should be avoided if possible. The first reaction to swapping should be to check for an unreasonable command such as trying to edit a five gigabyte file. If swapping becomes a normal occurrence, the best solution is to purchase more RAM for your system. 


```bash
# create a partition
mkfs -v -t ext4 /dev/<xxx>
# create a swap partition
mkswap /dev/<yyy>
```


```bash
# setup the $LFS variable
export LFS=/mnt/lfs
```

> You should ensure that this variable is always defined throughout the LFS build process. It should be set to the name of the directory where you will be building your LFS system - we will use /mnt/lfs as an example, but you may choose any directory name you want.

```bash 
#Create the mount point and mount the LFS file system with these commands: 
mkdir -pv $LFS
mount -v -t ext4 /dev/<xxx> $LFS
#If you are using multiple partitions for LFS (e.g., one for / and another for /home), mount them like this:
mkdir -pv $LFS
mount -v -t ext4 /dev/<xxx> $LFS
mkdir -v $LFS/home
mount -v -t ext4 /dev/<yyy> $LFS/home
```

## RESSOURCE

- [LFS book](https://www.linuxfromscratch.org/lfs/view/stable/index.html)


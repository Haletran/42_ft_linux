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


## STEPS


```bash
# check if the requirements are met
sudo bash check_requirements.sh

# setup lfs (wget the book, create the lfs user, create the lfs partition)
sudo bash create_lfs.sh

# login as lfs user
su - lfs

# setup env
./setup_env.sh

# install and the build packages toolkit
./install_packages.sh

# setup base system
./setup_base.sh

# launch the shell
exec /tools/bin/bash --login +h

# install apps
./install_apps.sh

# Here i am : https://www.fr.linuxfromscratch.org/view/lfs-8.2-fr/chapter06/kernfs.html

```

## RESSOURCE

- [LFS book 8.2](https://www.fr.linuxfromscratch.org/view/lfs-8.2-fr/index.html)
- [ChrisTitusTech LFS video](https://www.youtube.com/watch?v=oV541sgHKGo)

#!/bin/bash

echo "exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash" >> ~/.bash_profile

echo "set +h \
      umask 022 \ 
      LFS=/mnt/lfs \
      LC_ALL=POSIX \
      LFS_TGT=$(uname -m)-lfs-linux-gnu \
      PATH=/tools/bin:/bin:/usr/bin \
      export LFS LC_ALL LFS_TGT PATH" >> ~/.bashrc

source ~/.bash_profile
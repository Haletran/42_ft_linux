#!/bin/bash

cd $LFS/sources
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
cd .. && rm -rf gcc-14.2.0

tar -xvf linux-6.10.5.tar.xz && cd linux-6.10.5
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete

# sudo mkdir -v usr
# sudo chown -R lfs:lfs /mnt/lfs/usr
cp -rv usr/include $LFS/usr
cd .. && rm -rf linux-6.10.5
tar -xvf glibc-2.40.tar.xz && cd glibc-2.40
patch -Np1 -i ../glibc-2.40-fhs-1.patch
echo "rootsbindir=/usr/sbin" > configparms
mkdir -v build && cd build

../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=4.19               \
      --with-headers=$LFS/usr/include    \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib

make #-j1 if problems
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

# check if everything is setup correctly 
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux

rm -v a.out
cd ../.. && rm -rf glibc-2.40

cd gcc-14.2.0
mkdir -v build && cd build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0

make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

cd ../.. && rm -rf gcc-14.2.0
tar -xvf m4-1.4.19.tar.xz && cd m4-1.4.19
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
cd .. && rm -rf m4-1.4.19

tar -xvf ncurses-6.5.tar.gz && cd ncurses-6.5
sed -i s/mawk// configure
mkdir build

pushd build
  ../configure
  make -C include
  make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping


cd build && make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

cd ../.. && rm -rf ncurses-6.5


# bash will not work if ncurses is not installed correctly
tar -xvf bash-5.2.32.tar.gz && cd bash-5.2.32
./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc              \
            bash_cv_strtold_broken=no

make
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh

cd ..
tar -xvf coreutils-9.5.tar.xz && cd coreutils-9.5
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

cd .. && rm -rf coreutils-9.5
tar -xvf diffutils-3.10.tar.xz && cd diffutils-3.10
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install
cd .. && rm -rf diffutils-3.10


tar -xvf file-5.45.tar.gz && cd file-5.45
mkdir build && cd build

pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

cd .. && ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install\
rm -v $LFS/usr/lib/libmagic.la

cd .. && rm -rf file-5.45
tar -xvf findutils-4.10.0.tar.xz && cd findutils-4.10.0
make
make DESTDIR=$LFS install


cd .. && rm -rf findutils-4.10.0
tar -xvf gawk-5.3.0.tar.xz && cd gawk-5.3.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install


cd .. && rm -rf gawk-5.3.0
tar -xvf grep-3.11.tar.xz && cd grep-3.11
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install


cd .. && rm -rf grep-3.11
tar -xvf gzip-1.13.tar.xz && cd gzip-1.13
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd .. && rm -rf gzip-1.13
tar -xvf make-4.4.1.tar.gz && cd make-4.4.1
./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install


cd .. && rm -rf make-4.4.1
tar -xvf patch-2.7.6.tar.gz && cd patch-2.7.6
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd .. && rm -rf patch-2.7.6
tar -xvf sed-4.9.tar.xz && cd sed-4.9
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install

cd .. && rm -rf sed-4.9
tar -xvf tar-1.35.tar.xz && cd tar-1.35
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd .. && rm -rf tar-1.35
tar -xvf xz-5.6.2.tar.xf && cd xz-5.6.2
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.6.2
make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la

cd .. && rm -rf xz-5.6.2
tar -xvf binutils-2.43.1.tar.xz && cd binutils-2.43.1
sed '6009s/$add_dir//' -i ltmain.sh
mkdir -v build
cd       build


../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu

make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

cd .. && rm -rf binutils-2.43.1
tar -xvf gcc-14.2.0.tar.xz && cd gcc-14.2.0
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
cd       build

../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libsanitizer                         \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++

make
make DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc
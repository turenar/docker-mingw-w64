#!/bin/bash -eux

BUILD_DEPS=(libgmp-dev libmpfr-dev libmpc-dev make wget bzip2 texinfo)
DEPS=(libgmp10 libmpfr6 libmpc3 xz-utils g++)

case ${TARGET_BITS} in
	64) triplet=x86_64-w64-mingw32;;
	32) triplet=i686-w64-mingw32;;
	*)  echo "TARGET_BITS must be one of (32,64)">&2; exit 1;;
esac
PREFIX=/usr/local/${triplet}

apt-get install -y "${BUILD_DEPS[@]}" "${DEPS[@]}"

mkdir /tmp/mingw-w64-build
cd /tmp/mingw-w64-build

wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz -O - | tar -xJ
wget -q https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v${MINGW_VERSION}.tar.bz2 -O - | tar -xj
wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz -O - | tar -xJ
wget -q http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.xz -O - | tar -xJ

# binutils
mkdir build-binutils
cd build-binutils
../binutils-${BINUTILS_VERSION}/configure \
	--prefix=/usr/local \
	--target=${triplet} \
	--disable-multilib
make -j$(nproc)
make install
cd ..

# mingw-w64-header
mkdir build-mingw-w64-header
cd build-mingw-w64-header
../mingw-w64-v${MINGW_VERSION}/mingw-w64-headers/configure \
	--prefix=${PREFIX} \
	--host=${triplet} \
	--enable-sdk=all \
	--enable-secure-api
make install
cd ..

ln -s ${PREFIX} /usr/local/mingw
#mkdir ${PREFIX}/lib
#ln -s ${PREFIX}/lib ${PREFIX}/lib${TARGET_BITS}

# gcc core
mkdir build-gcc
cd build-gcc
../gcc-${GCC_VERSION}/configure \
	--target=${triplet} \
	--prefix=/usr/local \
	--disable-multilib \
	--enable-languages=c,c++
make -j$(nproc) all-gcc
make -j$(nproc) install-gcc
cd ..

# mingw-w64-crt
mkdir build-mingw-w64-crt
cd build-mingw-w64-crt
../mingw-w64-v${MINGW_VERSION}/mingw-w64-crt/configure \
	--host=${triplet} \
	--prefix=${PREFIX}
make -j$(nproc)
make install
cd ..

# winpthreads
mkdir build-winpthreads
cd build-winpthreads
../mingw-w64-v${MINGW_VERSION}/mingw-w64-libraries/winpthreads/configure \
	--host=${triplet} \
	--prefix=${PREFIX}
make -j$(nproc)
make install
cd ..

# gcc
cd build-gcc
../gcc-${GCC_VERSION}/configure \
	--target=${triplet} \
	--prefix=/usr/local \
	--disable-multilib \
	--enable-languages=c,c++ \
	--enable-threads=${GCC_THREAD_MODEL}
make -j$(nproc)
make install
cd ..

# gdb
mkdir build-gdb
cd build-gdb
../gdb-${GDB_VERSION}/configure \
	--target=${triplet}
make -j$(nproc)
make install
cd ..


cd /
rm -rf /tmp/mingw-w64-build

apt-get remove -y --purge "${BUILD_DEPS[@]}"
apt-get clean -y
rm -rf /var/lib/apt/lists/*

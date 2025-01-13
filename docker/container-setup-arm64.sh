#!/bin/bash

set -eu

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
target_user="${1:-cs300-user}"

export DEBIAN_FRONTEND=noninteractive

apt-get update &&\
    apt-get -y install unminimize

yes | unminimize

apt-get -y install binfmt-support

# include multiarch support
apt-get -y install binfmt-support &&\
  dpkg --add-architecture amd64 &&\
  apt-get update &&\
  apt-get upgrade

# install GCC-related packages
apt-get -y install\
	binutils-doc\
	cpp-doc\
	gcc-doc\
	g++\
	gdb\
	gdb-doc\
	gdbserver\
	glibc-doc\
	libblas-dev\
	liblapack-dev\
	liblapack-doc\
	libstdc++-11-doc\
	make\
	make-doc

# install GCC-related packages for amd64
apt-get -y install\
	g++-13-x86-64-linux-gnu\
	gdb-multiarch\
	libc6:amd64\
	libstdc++6:amd64\
	libasan8:amd64\
	libtsan2:amd64\
	libubsan1:amd64\
	libreadline-dev:amd64\
	libblas-dev:amd64\
	liblapack-dev:amd64\
	qemu-user

# # link x86-64 versions of common tools into /usr/x86_64-linux-gnu/bin
for i in addr2line c++filt cpp-13 g++-13 gcc-13 gcov-13 gcov-dump-13 gcov-tool-13 size strings; do \
    ln -s /usr/bin/x86_64-linux-gnu-$i /usr/x86_64-linux-gnu/bin/$i; done && \
    ln -s /usr/bin/x86_64-linux-gnu-cpp-13 /usr/x86_64-linux-gnu/bin/cpp && \
    ln -s /usr/bin/x86_64-linux-gnu-g++-13 /usr/x86_64-linux-gnu/bin/c++ && \
    ln -s /usr/bin/x86_64-linux-gnu-g++-13 /usr/x86_64-linux-gnu/bin/g++ && \
    ln -s /usr/bin/x86_64-linux-gnu-gcc-13 /usr/x86_64-linux-gnu/bin/gcc && \
    ln -s /usr/bin/x86_64-linux-gnu-gcc-13 /usr/x86_64-linux-gnu/bin/cc && \
    ln -s /usr/bin/gdb-multiarch /usr/x86_64-linux-gnu/bin/gdb

# Do main setup
$SCRIPT_DIR/container-setup-common $target_user

# create binary reporting version of dockerfile
(echo '#\!/bin/sh'; echo 'if test "x$1" = x-n; then echo 1; else echo 1.arm64; fi') > /usr/bin/cs300-docker-version && chmod ugo+rx,u+w,go-w /usr/bin/cs300-docker-version

rm -f /root/.bash_logout

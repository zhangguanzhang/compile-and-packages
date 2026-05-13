#!/bin/bash

set -x

BASE_DIR=/opt

sed -ri 's/[a-zA-Z0-9.]+(debian.org|ubuntu.com)/mirrors.aliyun.com/g' /etc/apt/sources.list
apt update

apt -y install \
    make git gcc python3-venv python3-tomli rename \
    ninja-build build-essential zlib1g-dev pkg-config libglib2.0-dev binutils-dev libpixman-1-dev libfdt-dev
    
cd ${CODE_DIR}

## https://lists.nongnu.org/archive/html/qemu-devel/2026-04/msg01286.html
#sed_num=$(grep -n -E '#if !defined\(TARGET_RISCV64\) \|\|.+TARGET_LOONGARCH64' linux-user/syscall_defs.h | awk -F: '{print $1}')
#if [ -n "$sed_num" ];then
#  sed -ri "${sed_num}s#\|\| defined\(TARGET_LOONGARCH64\)#\&\& !defined(TARGET_LOONGARCH64)#" linux-user/syscall_defs.h
#fi

./configure \
  --static \
  --disable-system \
  --enable-linux-user \
  --target-list=${TARGET_LIST}

make -j$(nproc)
make install DESTDIR=/mnt

prename -v 's/$/-static/'  /mnt/usr/local/bin/qemu-*

cp /mnt/usr/local/bin/qemu-*-static ${BASE_DIR}

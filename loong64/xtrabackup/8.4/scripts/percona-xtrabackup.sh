#!/bin/bash

set -ex
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

VERSION=percona-xtrabackup-8.4.0-5
BUILD_SH="https://raw.githubusercontent.com/percona/percona-xtrabackup/${VERSION}/storage/innobase/xtrabackup/utils/percona-xtrabackup-8.0_builder.sh"
BUILD_DIR=/data

LOG_FILE="/var/log/build.log"

log_init() {
    exec > >(tee -a "$LOG_FILE") 2>&1
}

install_gcc(){
    # CMake Error at cmake/os/Linux.cmake:73 (MESSAGE):                                                                                                                                                                                           
    #   GCC 10 or newer is required                                                                                                                                                                                                               
    # Call Stack (most recent call first):                                                                                                                                                                                                        
    #   CMakeLists.txt:645 (INCLUDE)

    if [ -f /tmp/gcc-installed.flag ];then
        return
    fi

    apt install -y --no-install-recommends \
        rpm2cpio cpio \
        libgmp-dev libmpfr-dev libmpc-dev

    wget https://pkg.loongnix.cn/loongnix-server/8.4/BaseOS/Source/SPackages/devtoolset-10-gcc-10.3.1-3.lns8.src.rpm
    mkdir -p gcc-10.3.1
    cd gcc-10.3.1
    rpm2cpio ../devtoolset-10-gcc-10.3.1-3.lns8.src.rpm | cpio -idmv
    tar zxf gcc-10.3.*.tar.gz
    cd gcc-10.3.?
    git apply ../*.patch
    cd ..
    mkdir -p gcc_objdir
    cd gcc_objdir
    ../gcc-10.3.?/configure -v \
        --with-bugurl=file:///usr/share/doc/gcc-10/README.Bugs \
        --enable-languages=c,c++ \
        --prefix=/opt/gcc-10 \
        --with-gcc-major-version-only \
        --enable-shared \
        --enable-linker-build-id \
        --libexecdir=/usr/libexec \
        --without-included-gettext \
        --enable-threads=posix \
        --enable-checking=release \
        --libdir=/opt/gcc-10/lib \
        --enable-nls \
        --enable-clocale=gnu \
        --with-default-libstdcxx-abi=new \
        --disable-libunwind-exceptions \
        --enable-gnu-unique-object \
        --with-linker-hash-style=gnu \
        --disable-bootstrap \
        --disable-libquadmath \
        --disable-libquadmath-support \
        --disable-multilib \
        --enable-plugin \
        --with-system-zlib \
        --disable-werror \
        --enable-gnu-indirect-function \
        --with-arch=loongarch64 \
        --with-abi=lp64d \
        --build=loongarch64-linux-gnu \
        --host=loongarch64-linux-gnu \
        --target=loongarch64-linux-gnu
    make -j$(nproc)
    make install
    cd ../../
    rm -rf devtoolset-10-gcc-*.src.rpm gcc-10.3.?

        
    # # https://gcc.gnu.org/wiki/InstallingGCC
    # if [ ! -d gcc-12.5.0 ];then
    #     wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-12.5.0/gcc-12.5.0.tar.gz
    #     tar -xzf gcc-12.5.0.tar.gz
    # fi
    # if [ ! -d gcc_objdir ];then
    #     cd gcc-12.5.0
    #     ./contrib/download_prerequisites
    #     find . -name "config.guess" | xargs -I {} cp /tmp/config.guess {}
    #     find . -name "config.sub"   | xargs -I {} cp /tmp/config.sub {}
    #     cd ..
    #     mkdir gcc_objdir
    # fi
    # cd gcc_objdir
    # # https://gcc.gnu.org/install/configure.html
    # ../gcc-12.5.0/configure -v \
    #     --with-bugurl=file:///usr/share/doc/gcc-12/README.Bugs \
    #     --enable-languages=c,c++ \
    #     --prefix=/usr \
    #     --with-gcc-major-version-only \
    #     --program-suffix=-12 \
    #     --program-prefix=loongarch64-linux-gnu- \
    #     --enable-shared \
    #     --enable-linker-build-id \
    #     --libexecdir=/usr/libexec \
    #     --without-included-gettext \
    #     --enable-threads=posix \
    #     --enable-checking=release \
    #     --libdir=/usr/lib \
    #     --enable-nls \
    #     --enable-clocale=gnu \
    #     --with-default-libstdcxx-abi=new \
    #     --disable-libunwind-exceptions \
    #     --enable-gnu-unique-object \
    #     --with-linker-hash-style=gnu \
    #     --disable-bootstrap \
    #     --disable-libquadmath \
    #     --disable-libquadmath-support \
    #     --disable-multilib \
    #     --enable-plugin \
    #     --with-system-zlib \
    #     --disable-werror \
    #     --enable-gnu-indirect-function \
    #     --with-arch=loongarch64 \
    #     --with-abi=lp64d \
    #     --build=loongarch64-linux-gnu \
    #     --host=loongarch64-linux-gnu \
    #     --target=loongarch64-linux-gnu
    # make -j$(nproc)
    # make install
    # cd ..
    touch /tmp/gcc-installed.flag
}

fake_deps(){
    local package_name=$1 version=$2
cat > ${package_name} <<EOF
Package: ${package_name}
Version: ${version}
Description: fake ${package_name} package
EOF
    equivs-build ${package_name}
    dpkg -i ${package_name}_*deb
    rm -f ${package_name}_*deb ${package_name}
}

install_dep(){
    local VERSION
    . /etc/os-release
    if [ -f /etc/apt/sources.list.d/debian.sources ];then
        sed -ri '\@deb.debian.org/debian@s/[a-zA-Z0-9.]+(debian.org|ubuntu.com)/mirrors.aliyun.com/g' \
            /etc/apt/sources.list.d/debian.sources
    fi
    apt update; \
    # https://docs.percona.com/percona-xtrabackup/8.4/compile-xtrabackup.html#2-installation-prerequisites
    # Note, selecting 'zlib1g-dev' instead of 'libz-dev'
    # Note, selecting 'libgcrypt20-dev' instead of 'libgcrypt-dev'
    apt install -y --no-install-recommends \
        curl wget git rsync \
        make \
        gcc g++ pkg-config patchelf \
        automake bison libssl-dev libncurses-dev libcurl4-openssl-dev libgcrypt20-dev zlib1g-dev libev-dev \
        gnupg2 lsb-release \
        dpkg-dev devscripts libdistro-info-perl vim-common \
        debhelper fakeroot libsasl2-dev build-essential libtool libaio-dev
    if [ -f /etc/apt/sources.list.d/debian.sources ];then
        apt install -y --no-install-recommends cmake libproc2-dev python3-docutils python3-sphinx
    else
        export PATH=/opt/gcc-10/bin:$PATH
        export LD_LIBRARY_PATH=/opt/gcc-10/lib:$LD_LIBRARY_PATH
        export CC=/opt/gcc-10/bin/gcc
        export CXX=/opt/gcc-10/bin/g++
        apt install -y --no-install-recommends python3-pip libprocps-dev equivs
        if [ ! -f /tmp/config.guess ];then
            wget -O /tmp/config.guess https://raw.githubusercontent.com/Loongson-Cloud-Community/docker-library/refs/heads/main/library/redis/6.2.19-alpine3.21/config.guess
        fi
        if [ ! -f /tmp/config.sub ];then
            wget -O /tmp/config.sub https://raw.githubusercontent.com/Loongson-Cloud-Community/docker-library/refs/heads/main/library/redis/6.2.19-alpine3.21/config.sub
        fi
    # + cmake . -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/data/boost -DFORCE_INSOURCE_BUILD=1 -DWITH_MAN_PAGES=1                                                                                                                                           
    # -- Running cmake version 3.13.4                                                                                                                                                                                                             
    # CMake Error at CMakeLists.txt:115 (CMAKE_MINIMUM_REQUIRED):                                                                                                                                                                                 
    # CMake 3.14.6 or higher is required.  You are running version 3.13.4 
        if ! command -v cmake &> /dev/null;then
            wget https://github.com/Kitware/CMake/releases/download/v3.31.12/cmake-3.31.12.tar.gz
            tar -xzf cmake-3.31.12.tar.gz
            cd cmake-3.31.12
            ./bootstrap
            make -j$(nproc)
            make install
            cd ..
            rm -rf cmake-3.31.12 cmake-3.31.12.tar.gz
            fake_deps cmake 3.31.12
            python3 -m pip install -i https://pypi.loongnix.cn/loongson/pypi/+simple/ docutils==0.16 sphinx==1.8.6
            fake_deps python3-docutils 0.16
            fake_deps python3-sphinx 1.8.6

        fi
        install_gcc
    fi
}

build(){
    export DEBFULLNAME="Percona Server Development Team"
    export DEBEMAIL="mysql-dev@percona.com"

    if [ ! -f /tmp/builder.sh ];then
        curl -o builder.sh $BUILD_SH
        BUILD_SH_NAME=$(basename $BUILD_SH)
        LOCK_FILE=/tmp/${BUILD_SH_NAME}.lock
        PATCH_FILE="${CUR_DIR}/patch/${VERSION}/${BUILD_SH_NAME}.patch"
        if [ -f "${PATCH_FILE}" ] && [ ! -f "${LOCK_FILE}" ];then
            patch builder.sh -i ${PATCH_FILE}
            touch ${LOCK_FILE}
        fi
        mv builder.sh /tmp/builder.sh
    fi
    # clone 失败的话目录还存在的话需要手动删除下
    # rm -rf ${BUILD_DIR}/percona-xtrabackup
    bash -x /tmp/builder.sh --builddir=${BUILD_DIR} --branch=${VERSION} --get_sources=1 --build_source_deb=1 --build_deb=1
}

clean(){
    rm -f percona-xtrabackup-8.0.properties
}

# 会卡住上面的git clone
# log_init
install_dep
build
clean

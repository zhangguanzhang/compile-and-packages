#!/bin/bash
set -ex
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

VERSION=Percona-Server-8.4.7-7
BUILD_SH="https://raw.githubusercontent.com/percona/percona-server/${VERSION}/build-ps/percona-server-8.0_builder.sh"
BUILD_DIR=/data
LOG_FILE="/var/log/build.log"

log_init() {
    exec > >(tee -a "$LOG_FILE") 2>&1
}

install_dep(){
    . /etc/os-release
    if [ -f /etc/apt/sources.list.d/debian.sources ];then
        sed -ri '\@deb.debian.org/debian@s/[a-zA-Z0-9.]+(debian.org|ubuntu.com)/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources
    fi
    apt update; \
    # 不能安装 libfido2-dev，https://github.com/percona/percona-server/commit/b4523085027726e243f32a6bc855f7115c70c3b0
    # 应该让走到 internal 让生成 build-ps/debian/percona-server-server.install 里的 authentication_webauthn_client.so 
    apt install -y --no-install-recommends \
        curl wget git rsync gnupg2 lsb-release cmake autotools-dev autoconf automake make unzip perl  \
        gcc g++ pkg-config patchelf build-essential psmisc bison libssl-dev zlib1g-dev libev-dev \
        libncurses-dev libcurl4-openssl-dev libgcrypt20-dev libproc2-dev libaio-dev  \
        ccache libevent-dev liblz4-dev libre2-dev libtool po-debconf \
        dpkg-dev devscripts doxygen doxygen-gui graphviz copyright-update libdistro-info-perl debhelper vim-common fakeroot python3-docutils python3-sphinx \
        libfido2-1 libcbor0.10 libldap2-dev libsasl2-dev libsasl2-dev libsasl2-modules libsasl2-modules-gssapi-mit libkrb5-dev \
        libnuma-dev libwrap0-dev libtirpc-dev libmecab-dev libpam-dev libudev-dev
}

build(){
    export DEBFULLNAME="Percona Server Development Team"
    export DEBEMAIL="mysql-dev@percona.com"
    # export SKIP_DEBUG_BINARY=1 似乎有问题，一些 debian/xxx.install 里会有 debug/xxx.so 安装

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
    # rm -rf ${BUILD_DIR}/percona-server
    bash -x /tmp/builder.sh --builddir=${BUILD_DIR} --branch=${VERSION} --get_sources=1 --build_source_deb=1 --build_deb=1
}

clean(){
    rm -f percona-server*.properties
}

# 会卡住上面的git clone
# log_init
install_dep
build
clean

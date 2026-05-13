ARG IMG=m.daocloud.io/docker.io/library/debian:trixie-slim
FROM ${IMG}

RUN set -eux; \
    sed -ri '\@deb.debian.org/debian@s/[a-zA-Z0-9.]+(debian.org|ubuntu.com)/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources; \
    apt update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        openssh-client \
        curl \
        file \
        git \
        dpkg-dev \
        pigz \
        cmake make pkg-config \
        wget xz-utils \
        gcc libc6-dev gawk pkg-config \
        gcc-loongarch64-linux-gnu libc-dev-loong64-cross \
    ; \
    apt clean; \
    rm -rf /var/cache/apk/* /tmp/* /var/cache/apt/* /var/lib/apt/lists/*; 

# http://www.loongnix.cn/zh/toolchain/GNU/
RUN set -eux; \
    cd /; \
    wget https://ftp.loongnix.cn/toolchain/gcc/release/loongarch/gcc8/loongson-gnu-toolchain-8.3-x86_64-loongarch64-linux-gnu-rc1.6.tar.xz; \
    tar xfJp loongson-gnu-toolchain-*.tar.xz; \
    rm -f loongson-gnu-toolchain-*.tar.xz; \
    mv loongson-gnu-toolchain-*-x86_64-* loongson-gnu-toolchain

RUN set -eux; \
    mkdir -p ~/.ssh/; \
    chmod 0700 ~/.ssh/; \
    touch ~/.ssh/known_hosts ~/.ssh/authorized_keys; \
    chmod 0600 ~/.ssh/known_hosts ~/.ssh/authorized_keys; 

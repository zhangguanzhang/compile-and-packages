ARG IMG=lcr.loongnix.cn/library/debian:14-slim
FROM ${IMG}

ARG DIST_URL

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

ENV CALL_HOME_DOWNLOAD_SHA256 5e84d2f1a5d57f44c46e6a1f16794d649d3de09fe8021f0294bc321c89e51068
ENV CALL_HOME_VERSION 0.1

# create mysql user/group before mysql installation
RUN groupadd -g 1001 mysql; \
    useradd -u 1001 -r -g 1001 -s /sbin/nologin \
        -c "Default Application User" mysql

RUN set -eux; \
    sed -ri '\@deb.debian.org/debian@s/[a-zA-Z0-9.]+(debian.org|ubuntu.com)/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources; \
    apt update; \
    apt install -y --no-install-recommends \
        curl vim tzdata binutils ca-certificates \
        # xtrabackup 依赖
        rsync zstd lz4 libgcrypt20 libproc2-0 libaio1t64 \
    ; \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \ 
    for deb in percona-xtrabackup-84 percona-server-common_ percona-server-client_ ; do \
        current_deb=$(curl -s ${DIST_URL} | grep -Po 'href="\K'"${deb}"'[^"]+loong64.deb'); \
        curl -o ${current_deb} -s ${DIST_URL}/${current_deb}; \
        apt install -y --no-install-recommends ./${current_deb}; \
    done; \
    xtrabackup_path=$(which xtrabackup); \
    rm -f ${xtrabackup_path}-debug; \
    xtrabackup --version; \
    # 只需要里面的 mysqlbinlog 二进制
    client_deb=$(curl -s ${DIST_URL} | grep -Po 'href="\Kpercona-server-server[^"]+loong64.deb'); \
    curl -o ${client_deb} -s ${DIST_URL}/${client_deb}; \
# dpkg-deb -x ${client_deb} fs; 权限问题换 ar x + tar
    mkdir -p fs; \
    cd fs; \
    ar x ../${client_deb}; \
    tar xf data.tar.gz --no-same-owner --no-same-permissions; \
    cd ..; \
    mysqlbinlog_path=$(find fs/ -type f -name mysqlbinlog); \
    mv ${mysqlbinlog_path} /usr/bin/; \
    mysqlbinlog --version; \
    mysql --version; \
    apt clean all;  \
    rm -rf *.deb fs/ /var/cache/apt/archives /var/lib/apt/lists/*;

RUN install -d -o 1001 -g 0 -m 0775 /backup

RUN set -eux; \
    curl -fL "https://github.com/Percona-Lab/telemetry-agent/archive/refs/tags/phase-$CALL_HOME_VERSION.tar.gz" -o "phase-$CALL_HOME_VERSION.tar.gz"; \
    echo "$CALL_HOME_DOWNLOAD_SHA256 phase-$CALL_HOME_VERSION.tar.gz" | sha256sum --strict --check; \
    tar -xvf phase-$CALL_HOME_VERSION.tar.gz --no-same-owner --no-same-permissions; \
    cp telemetry-agent-phase-$CALL_HOME_VERSION/call-home.sh .;\
    rm -rf telemetry-agent-phase-$CALL_HOME_VERSION phase-$CALL_HOME_VERSION.tar.gz; \
    chmod a+rx /call-home.sh; \
    mkdir -p /usr/local/percona; \
    chown mysql:mysql /usr/local/percona
ENV CALL_HOME_OPTIONAL_PARAMS=" -s ${OS_VER}"

RUN set -eux; \
    curl -sSL -o /docker-entrypoint.sh https://raw.githubusercontent.com/percona/percona-docker/refs/heads/main/percona-xtrabackup-8.x/pxb-entry.sh; \
    chmod a+x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME [ "/backup" ]
USER 1001

CMD ["/usr/bin/xtrabackup"]

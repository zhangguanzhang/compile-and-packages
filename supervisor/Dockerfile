ARG BASE_IMG=centos:7
FROM ${BASE_IMG} AS rpm
ARG version=4.2.4

RUN if ! command -v rpmbuild;then yum install -y rpm-build; fi

# 必须 /root/rpmbuild
WORKDIR /root/rpmbuild
COPY rpmbuild .

RUN case "$(uname -m)" in \
    'amd64' | 'x86_64') \
        GOARCH='amd64' \
        ;; \
    'mips64' | 'mips64le' | 'mips64el') \
        GOARCH='mips64el' \
        ;; \
    'aarch64') \
        GOARCH='arm64' \
        ;; \
    esac \
    \
    && find SOURCES -type f -name '*.sh' -exec chmod a+x {} \; && \
    rpmbuild -bb SPECS/supervisor.spec --define="GOARCH $GOARCH" --define="version ${version}"

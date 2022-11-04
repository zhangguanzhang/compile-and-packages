ARG BASE_IMG=centos:7
FROM ${BASE_IMG} AS rpm
ARG version=4.2.4
ARG env_file_support=1

# 利用 python3 的 pip 安装 supervisor 和 pyinstaller , pyinstaller 依赖系统有 binutils
RUN . /etc/os-release && \
	pip_list="" && \
	case "$NAME" in \
        "Kylin Linux Advanced Server") \
			pkg_list="python3-pip binutils" \
            ;; \
        "CentOS Linux") \
			pkg_list="python3-pip binutils gcc zlib-devel which rpm-build" \
			pip_list="wheel" \
            ;; \
        *) \
			echo "暂未适配，自行查找包名" \
			exit 2 \
            ;; \
    esac \
    \
    && yum install -y $pkg_list && \
	if [ -n "$pip_list" ];then pip3 install $pip_list; fi && \
	pip3 install pyinstaller && \
	pip3 install supervisor==${version}

# 必须 /root/rpmbuild
WORKDIR /root/rpmbuild

COPY rpmbuild/SOURCES/build/ /tmp/

# hack 添加 environment_file 支持
RUN mkdir -p SOURCES RPMS && \
    if [ "${env_file_support}" -ne 0 ];then bash /tmp/build.sh;touch RPMS/hack.flag; fi && \
# 相关文件可以通过 rpm -ql supervisor | grep -Pv '\.py|/site-packages/|/share/'
# /usr/local/lib/python3.7/site-packages/
    op_file=$(find /usr/ -type f -name 'options.py' -path '*/supervisor/*') && \
    #sed -ri "/^VERSION\s+=\s+/s/= .+/= \"${ver}\"#" $op_file && \
    sed -ri '/^VERSION\s+=\s+/s#= .+#= "'"${ver}"'"#' $op_file && \
	dir=$(find /usr -type d -name supervisor -path '*/site-packages/*'  -exec dirname {} \;) && \
	pyinstaller --onefile -p $dir `which pidproxy` && \
	pyinstaller --onefile -p $dir `which supervisord` && \
	pyinstaller --onefile -p $dir `which supervisorctl` && \
    pyinstaller --onefile -p $dir `which echo_supervisord_conf` && \
	mv dist/* SOURCES/

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

FROM scratch AS bin
COPY --from=rpm /root/rpmbuild/RPMS /

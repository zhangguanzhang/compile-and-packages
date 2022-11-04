Summary: A System for Allowing the Control of Process State on UNIX
Name: supervisor

%define version 4.2.4
Version: %{version}
Release: 1%{?dist}

# 如果提前准备好二进制，则 build 阶段不执行 pyinstaller 打包操作
%define bin_file "%(ls $PWD/SOURCES/supervisord 2>/dev/null)"

License: GPLv2
Group: System Environment/Base
URL: https://github.com/zhangguanzhang/compile-and-packages

Source0: supervisord.service
Source1: supervisord.conf
Source2: supervisor.logrotate
Source3: supervisor.tmpfiles

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%if %{GOARCH} == "amd64"
BuildArch:      x86_64
%endif
%if %{GOARCH} == "arm64"
BuildArch:      aarch64
%endif

# 确保构建的 rootfs 最低是支持 systemd
BuildRequires: systemd

Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
 
%description
The supervisor is a client/server system that allows its users to control a
number of processes on UNIX-like operating systems.
 
%prep
# 没压缩包， 不 setup
#%setup -q -n %{name}-%{version}%{?prever}
 
%build

if [ -z "%{bin_file}" ];then
    . /etc/os-release 
    pip_list=""
    case "$NAME" in
        "Kylin Linux Advanced Server")
            pkg_list="python3-pip binutils"
            ;;
        "CentOS Linux")
            pkg_list="python3-pip binutils gcc zlib-devel which rpm-build"
            pip_list="wheel"
            ;;
        *)
            echo "暂未适配，自行查找包名"
            exit 2
            ;;
    esac
    
    yum install -y $pkg_list
    if [ -n "$pip_list" ];then pip3 install $pip_list; fi
    pip3 install pyinstaller
    pip3 install supervisor==%{version}
    ver=$(find /usr/ -type f -name 'version.txt' -path '*/supervisor/*' -exec cat {} \; )
    op_file=$(find /usr/ -type f -name 'options.py' -path '*/supervisor/*')
    # 设置 VERSION
    sed -ri '/^VERSION\s+=\s+/s#= .+#= "'"${ver}"'"#' $op_file
    
    mkdir test
    (
        cd test
        dir=$(find /usr -type d -name supervisor -path '*/site-packages/*'  -exec dirname {} \;)
        pyinstaller --onefile -p $dir `which pidproxy`
        pyinstaller --onefile -p $dir `which supervisord`
        pyinstaller --onefile -p $dir `which supervisorctl`
        pyinstaller --onefile -p $dir `which echo_supervisord_conf`
        mv dist/* %_topdir/SOURCES/
    )
    rm -rf test
fi


%install
%{__rm} -rf %{buildroot}
#ls -l ../BUILD %_topdir/SOURCES/

%{__mkdir} -p %{buildroot}/%{_sysconfdir}
%{__mkdir} -p %{buildroot}/%{_sysconfdir}/supervisord.d
%{__mkdir} -p %{buildroot}/%{_sysconfdir}/logrotate.d/
%{__mkdir} -p %{buildroot}%{_unitdir}
%{__mkdir} -p %{buildroot}/%{_localstatedir}/log/%{name}
%{__mkdir} -p %{buildroot}/%{_localstatedir}/run/supervisor
%{__chmod} 770 %{buildroot}/%{_localstatedir}/log/%{name}
%{__chmod} 770 %{buildroot}/%{_localstatedir}/run/supervisor
%{__install} -p -m 644 %{SOURCE0} %{buildroot}%{_unitdir}/supervisord.service
%{__install} -p -m 644 %{SOURCE1} %{buildroot}/%{_sysconfdir}/supervisord.conf
%{__install} -p -m 644 %{SOURCE2} %{buildroot}/%{_sysconfdir}/logrotate.d/supervisor
%{__install} -D -p -m 0644 %{SOURCE3} %{buildroot}%{_sysconfdir}/tmpfiles.d/%{name}.conf

for file in supervisord supervisorctl pidproxy echo_supervisord_conf;do
    %{__install} -D -p -m 755 %_topdir/SOURCES/$file %{buildroot}/%{_bindir}/$file
done
if [ -z "%{bin_file}" ];then
    (
        cd %_topdir/SOURCES/
        %{__rm} -f supervisord supervisorctl pidproxy echo_supervisord_conf
    )
fi

%clean
%{__rm} -rf %{buildroot}
 
%post
%systemd_post %{name}.service
 
%preun
%systemd_preun %{name}.service
 
%postun
%systemd_postun %{name}.service
 
%files
%defattr(-,root,root,-)
%dir %{_localstatedir}/log/%{name}
%{_unitdir}/supervisord.service
%{_bindir}/supervisord
%{_bindir}/supervisorctl
%{_bindir}/pidproxy
%{_bindir}/echo_supervisord_conf
%{_localstatedir}/run/supervisor
%config(noreplace) %{_sysconfdir}/tmpfiles.d/%{name}.conf
%config(noreplace) %{_sysconfdir}/supervisord.conf
%dir %{_sysconfdir}/supervisord.d
%config(noreplace) %{_sysconfdir}/logrotate.d/supervisor
 
%changelog
* Fri Nov  4 2022 zhangguanzhang <zhangguanzhang@qq.com> - 4.2.4
- Initial packaging

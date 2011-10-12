Name:           suse-media-server
Requires:       nginx >= 1.0

Requires:       samba, minidlna, shellinabox, augeas, augeas-lenses, PolicyKit
Requires:       rubygem-passenger-nginx, rubygem-ruby-augeas, ruby-dbus

PreReq:         rubygem-rails-2_3 >= 2.3.8
PreReq:         rubygem-rake, rubygem-rpam, rubygem-polkit, rubygem-gettext_rails

License:        LGPL-2.0
Group:          Productivity/Networking/Web/Utilities
URL:            https://github.com/vlewin/suse-media-server
Autoreqprov:    on
Version:        0.2
Release:        0

Summary:        Web interface for SAMBA (file sharing) and DLNA (streaming) configuration
Source:         suse-media-server.tar.bz2
Source1:        augeas.dlna.Service.conf
Source2:        augeas.smb.Service.conf
Source3:        augeasDLNAService.rb
Source4:        augeasSMBService.rb
Source5:        augeas.dlna.Service.service
Source6:        augeas.smb.Service.service
Source7:        org.augeas.dlna.policy
Source8:        org.augeas.smb.policy
Source9:        nginx.conf
Source10:       wicd-rpmlintrc
Source11:       minidlna.aug
Source12:       rcsms

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby, pkg-config
BuildRequires:  ruby-dbus
BuildRequires:  PolicyKit, dbus-1
BuildRequires:  rubygem-rails-2_3 >= 2.3.8
BuildRequires:  rubygem-rpam, rubygem-polkit
BuildRequires:  nginx >= 1.0, rubygem-passenger-nginx
BuildRequires:  sqlite rubygem-sqlite3

BuildArch:      noarch

%define sms_dir /srv/www/suse-media-server
%define sms_user suse-media-server

%description
SUSE Media Server - is a web interface for SAMBA (file sharing) and DLNA (streaming) configuration

Authors:
Vladislav Lewin <vlewin@suse.de>

%prep

%build

%check

%install
mkdir -p $RPM_BUILD_ROOT/%{sms_dir}/log
tar -xvf %{SOURCE0} -C $RPM_BUILD_ROOT/%{sms_dir}
rm -rf $RPM_BUILD_ROOT/%{sms_dir}/log/*

# init script
mkdir -p %{buildroot}/etc/init.d
mkdir -p %{buildroot}/usr/sbin
%{__install} -D -m0755 %{SOURCE12} %{buildroot}/etc/init.d/suse-media-server
ln -s ../../etc/init.d/suse-media-server %{buildroot}/usr/sbin/rcsms

# Policies
mkdir -p $RPM_BUILD_ROOT/usr/share/PolicyKit/policy
install -m 0644 %{SOURCE7} $RPM_BUILD_ROOT/usr/share/PolicyKit/policy/
install -m 0644 %{SOURCE8} $RPM_BUILD_ROOT/usr/share/PolicyKit/policy/

#Dbus service permissions configuration
mkdir -p $RPM_BUILD_ROOT/etc/dbus-1/system.d/
install -m 0644 %{SOURCE1} $RPM_BUILD_ROOT/etc/dbus-1/system.d/
install -m 0644 %{SOURCE2} $RPM_BUILD_ROOT/etc/dbus-1/system.d/

# binary providing DBus service - place is specified in service config
mkdir -p $RPM_BUILD_ROOT/usr/sbin/
cp %{SOURCE3} $RPM_BUILD_ROOT/usr/sbin
cp %{SOURCE4} $RPM_BUILD_ROOT/usr/sbin

#Dbus service describotion
mkdir -p $RPM_BUILD_ROOT/usr/share/dbus-1/system-services/
install -m 0444 %{SOURCE5} $RPM_BUILD_ROOT/usr/share/dbus-1/system-services/
install -m 0444 %{SOURCE6} $RPM_BUILD_ROOT/usr/share/dbus-1/system-services/

mkdir -p $RPM_BUILD_ROOT/usr/share/libaugeas0/augeas/lenses/dist/
install -m 0444 %{SOURCE11} $RPM_BUILD_ROOT/usr/share/libaugeas0/augeas/lenses/dist/

#  create empty tmp directory
mkdir -p $RPM_BUILD_ROOT/%{sms_dir}/tmp
mkdir -p $RPM_BUILD_ROOT/%{sms_dir}/tmp/cache
mkdir -p $RPM_BUILD_ROOT/%{sms_dir}/tmp/pids
mkdir -p $RPM_BUILD_ROOT/%{sms_dir}/tmp/sessions
mkdir -p $RPM_BUILD_ROOT/%{sms_dir}/tmp/sockets

# configure nginx web service and create symlinks to nginx config files
mkdir -p $RPM_BUILD_ROOT/etc/suse-media-server/
install -m 0644 %SOURCE9 $RPM_BUILD_ROOT/etc/suse-media-server/
ln -s /etc/nginx/fastcgi.conf $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/fastcgi_params $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/koi-utf $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/koi-win $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/mime.types $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/scgi_params $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/uwsgi_params $RPM_BUILD_ROOT/etc/suse-media-server
ln -s /etc/nginx/win-utf $RPM_BUILD_ROOT/etc/suse-media-server

%clean
rm -rf $RPM_BUILD_ROOT

%pre
#/usr/sbin/groupadd -r suse-media-server &>/dev/null ||:
#/usr/sbin/useradd  -g suse-media-server -s /bin/false -r -c "User for SUSE Media Server" &>/dev/null ||:

%post
%fillup_and_insserv suse-media-server

cd %{sms_dir}
RAILS_ENV=production rake db:migrate
#use suse-media-server user instead of nginx
touch log/production.log

chown nginx.nginx db
chown nginx.nginx db/*
chown nginx.nginx log
chown nginx.nginx log/*


polkit-auth --user nginx --grant org.freedesktop.policykit.read > /dev/null || :
polkit-auth --user nginx --grant org.augeas.smb.read > /dev/null || :
polkit-auth --user nginx --grant org.augeas.smb.write > /dev/null || :
polkit-auth --user nginx --grant org.augeas.dlna.read > /dev/null || :
polkit-auth --user nginx --grant org.augeas.dlna.write > /dev/null || :

%preun
%stop_on_removal suse-media-server

%postun
%restart_on_update suse-media-server
%{insserv_cleanup}

%triggerin -- nginx
%restart_on_update rcsms

%files
%defattr(-,root,root)
%dir %{sms_dir}
%dir /etc/suse-media-server

%{sms_dir}/vendor
%{sms_dir}/app
%{sms_dir}/config
%{sms_dir}/db
%{sms_dir}/doc
%{sms_dir}/lib
%{sms_dir}/public
%{sms_dir}/script
%{sms_dir}/INSTALL
%{sms_dir}/LICENSE
%{sms_dir}/Rakefile
%{sms_dir}/README

/etc/init.d/suse-media-server
/usr/sbin/rcsms

%attr(-,nginx,nginx) %{sms_dir}/db
%attr(-,nginx,nginx) %{sms_dir}/log
%attr(-,nginx,nginx) %{sms_dir}/tmp

%attr(644,root,root) %config /etc/dbus-1/system.d/augeas.dlna.Service.conf
%attr(644,root,root) %config /etc/dbus-1/system.d/augeas.smb.Service.conf
%attr(755,root,root)  /usr/sbin/augeasDLNAService.rb
%attr(755,root,root)  /usr/sbin/augeasSMBService.rb
%attr(644,root,root)  /usr/share/dbus-1/system-services/augeas.dlna.Service.service
%attr(644,root,root)  /usr/share/dbus-1/system-services/augeas.smb.Service.service
%attr(644,root,root)  /usr/share/PolicyKit/policy/org.augeas.dlna.policy
%attr(644,root,root)  /usr/share/PolicyKit/policy/org.augeas.smb.policy

#install minidlna lense to augeas lenses location
/usr/share/libaugeas0
/usr/share/libaugeas0/*
%attr(755,root,root)  /usr/share/libaugeas0/augeas/lenses/dist/minidlna.aug

#nginx stuff
%dir /etc/suse-media-server
%config(noreplace) /etc/suse-media-server/nginx.conf
%config /etc/suse-media-server/fastcgi.conf
%config /etc/suse-media-server/fastcgi_params
%config /etc/suse-media-server/koi-utf
%config /etc/suse-media-server/koi-win
%config /etc/suse-media-server/mime.types
%config /etc/suse-media-server/scgi_params
%config /etc/suse-media-server/uwsgi_params
%config /etc/suse-media-server/win-utf
%doc %{sms_dir}/COPYING

%changelog


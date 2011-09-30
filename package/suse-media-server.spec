Name:           suse-media-server
Provides:       suse-media-server
PreReq:
License:        LGPL-2.0
Group:          Productivity/Networking/Web/Utilities
URL:            https://github.com/vlewin/suse-media-server
Autoreqprov:    on
Version:        0.1
Release:        0
Summary:        SUSE Media Server - Web Administration Tool for file sharing (SAMBA) and media streaming (DLNA)
Source:         www.tar.bz2
Source1:        example.service.conf
Source2:        exampleService.rb
Source3:        example.service.service
Source4:        org.example.plugin.policy
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
#BuildRequires:  rubygem-yast2-webservice-tasks rubygem-restility
#BuildRequires:  rubygem-test-unit rubygem-mocha
Requires: %{name} = %{version}
Requires: samba minidlna augeas augeas-lenses
Requires: ruby-dbus rubygem-ruby-augeas

#%define plugin_dir %{webyast_dir}/vendor/plugins/exampleplugin



%description
SUSE Media Server - is a web interface for SAMBA (file sharing) and DLNA (streaming) configuration

Authors:
Vladislav Lewin <vlewin@suse.de>

%prep
%setup -q -n www

%build
# build restdoc documentation
#mkdir -p public/ntp/restdoc
#%webyast_restdoc

# do not package restdoc sources
#rm -rf restdoc
#do not package development documentation
#rm -rf doc

%check
# run the testsuite
#%webyast_check

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT%{plugin_dir}
cp -a * $RPM_BUILD_ROOT%{plugin_dir}
rm -f $RPM_BUILD_ROOT%{plugin_dir}/COPYING

#Dbus service permissions configuration
mkdir -p $RPM_BUILD_ROOT/etc/dbus-1/system.d/
cp %{SOURCE1} $RPM_BUILD_ROOT/etc/dbus-1/system.d/
# binary providing DBus service - place is specified in service config
mkdir -p $RPM_BUILD_ROOT/usr/local/sbin/
cp %{SOURCE2} $RPM_BUILD_ROOT/usr/local/sbin
#Dbus service describotion
mkdir -p $RPM_BUILD_ROOT/usr/share/dbus-1/system-services/
cp %{SOURCE3} $RPM_BUILD_ROOT/usr/share/dbus-1/system-services/
#policies
mkdir -p $RPM_BUILD_ROOT/usr/share/PolicyKit/policy/
cp %{SOURCE4} $RPM_BUILD_ROOT/usr/share/PolicyKit/policy/

%clean
rm -rf $RPM_BUILD_ROOT

%post
# granting all permissions for the suse-media-server user and root
polkit-auth --user root --grant org.example.plugin.read org.example.plugin.write > /dev/null || :
polkit-auth --user %{webyast_user} --grant org.example.plugin.read org.example.plugin.write > /dev/null || :

%postun

%files
%defattr(-,root,root)
%dir %{webyast_dir}
%dir %{webyast_dir}/vendor
%dir %{webyast_dir}/vendor/plugins
%dir %{plugin_dir}
%{plugin_dir}/README
%{plugin_dir}/Rakefile
%{plugin_dir}/init.rb
%{plugin_dir}/install.rb
%{plugin_dir}/uninstall.rb
%{plugin_dir}/app
%{plugin_dir}/config
%attr(744,root,root) /usr/local/sbin/exampleService.rb
%attr(644,root,root) /usr/share/PolicyKit/policy/org.example.plugin.policy
%attr(644,root,root) /etc/dbus-1/system.d/example.service.conf
%attr(644,root,root) /usr/share/dbus-1/system-services/example.service.service


%changelog


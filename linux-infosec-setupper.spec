Name: linux-infosec-setupper
Summary: CLI and GUI utilities to setup information security-related parts of Linux
License: GPLv3
Group: System/Configuration/Other
Version: 0.2
Release: 1
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: bash
BuildRequires: make
BuildRequires: gettext

%description
%{summary}

#-----------------------------------------------------------------------------------

%package common
Summary: Common parts for subpackages of %{name}
Group: System/Configuration/Other
Requires: awk
Requires: bash
Requires: coreutils
Requires: grep
Requires: sed

%description common
Common parts for subpackages of %{name}

%files common
%dir %{_datadir}/linux-infosec-setupper
%{_datadir}/linux-infosec-setupper/common.sh
%dir %attr(0700,root,root) /var/lib/linux-infosec-setupper
%lang(ru) %{_datadir}/locale/ru/LC_MESSAGES/linux-infosec-setupper.mo

#-----------------------------------------------------------------------------------

%package auditd-cli
Summary: CLI and backend to setup auditd configs
Group: System/Configuration/Other
Requires: %{name}-common = %{version}-%{release}
Requires: audit

%description auditd-cli
CLI and backend to setup auditd configs

%files auditd-cli
%{_sbindir}/linux-infosec-setupper-auditd-cli
%dir %{_datadir}/linux-infosec-setupper/audit
%{_datadir}/linux-infosec-setupper/audit/back_auditd.sh
%dir %attr(0700,root,root) /var/lib/linux-infosec-setupper/audit
%ghost /var/lib/linux-infosec-setupper/audit/auditd-conf.sh

#-----------------------------------------------------------------------------------

%package auditd-gui
Summary: GUI to setup auditd configs
Group: System/Configuration/Other
Requires: %{name}-auditd-cli = %{version}-%{release}
Requires: yad
Recommends: polkit

%description auditd-gui
GUI to setup auditd configs

%files auditd-gui
%{_sbindir}/linux-infosec-setupper-auditd-gui
%{_bindir}/linux-infosec-setupper-auditd-gui
%{_datadir}/polkit-1/actions/org.nixtux.pkexec.linux-infosec-setupper-auditd-gui.policy

#-----------------------------------------------------------------------------------

%package pwquality-cli
Summary: CLI and backend to setup pwquality configs
Group: System/Configuration/Other
Requires: %{name}-common = %{version}-%{release}
%if 0%{?mdvver}
Requires: pam_pwquality
Requires: libpwquality-common
%else
# redhat
Requires: libpwquality
%endif

%description pwquality-cli
CLI and backend to setup pwquality configs

%files pwquality-cli
%{_sbindir}/linux-infosec-setupper-pwquality-cli
%dir %{_datadir}/linux-infosec-setupper/pwquality
%{_datadir}/linux-infosec-setupper/pwquality/back_pwquality.sh
%{_datadir}/linux-infosec-setupper/pwquality/pw_default
%dir %attr(0700,root,root) /var/lib/linux-infosec-setupper/pwquality
%ghost /var/lib/linux-infosec-setupper/pwquality/pw_changed

#-----------------------------------------------------------------------------------

%package pwquality-gui
Summary: GUI to setup pwquality configs
Group: System/Configuration/Other
Requires: %{name}-pwquality-cli = %{version}-%{release}
Requires: yad
Recommends: polkit

%description pwquality-gui
GUI to setup pwquality configs

%files pwquality-gui
%{_sbindir}/linux-infosec-setupper-pwquality-gui
%{_bindir}/linux-infosec-setupper-pwquality-gui
%{_datadir}/polkit-1/actions/org.nixtux.pkexec.linux-infosec-setupper-pwquality-gui.policy

#-----------------------------------------------------------------------------------

%prep
%autosetup -p1 -c

%build
%make_build

%install
%make_install

# ghost files
mkdir -p %{buildroot}/var/lib/linux-infosec-setupper/audit/
mkdir -p %{buildroot}/var/lib/linux-infosec-setupper/pwquality/
touch %{buildroot}/var/lib/linux-infosec-setupper/audit/auditd-conf.sh
touch %{buildroot}/var/lib/linux-infosec-setupper/pwquality/pw_changed

%check
bash -x ./test_back_auditd.sh

Name: linux-infosec-setupper
Summary: CLI and GUI utilities to setup information security-related parts of Linux
License: GPLv3
Group: System/Base
Version: 0.1
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
Group: System/Base
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

#-----------------------------------------------------------------------------------

%package auditd-cli
Summary: CLI and backend to setup auditd configs
Group: System/Base
Requires: %{name}-common = %{version}-%{release}
Requires: audit

%description auditd-cli
CLI and backend to setup auditd configs

%files auditd-cli
%dir %{_datadir}/linux-infosec-setupper/audit
%{_datadir}/linux-infosec-setupper/audit/back_auditd.sh
%dir %attr(0700,root,root) /var/lib/linux-infosec-setupper/audit
%lang(ru) %{_datadir}/locale/ru/LC_MESSAGES/linux-infosec-setupper-back_auditd.mo

#-----------------------------------------------------------------------------------

%prep
%autosetup -p1 -c

%build
%make_build

%install
%make_install

%check
bash -x ./test_back_auditd.sh

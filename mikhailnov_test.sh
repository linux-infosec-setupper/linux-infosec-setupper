#!/bin/bash

set -x
set -e

failed=0
tmpdir="$(mktemp -d)"
DESTDIR="$tmpdir"
echo "TMP DIR: $tmpdir"
. ./mikhailnov.sh

_exit(){
	# Catch exit != 0 from functions (fatal errors)
	if [ $? != 0 ]; then
		failed=$((++failed))
	fi
	if [ "$failed" -gt 0 ]; then
		echo "FAILED TESTS: $failed"
		exit 1
	fi
}
trap _exit EXIT ERR

_main(){
	{ _mk_systemd_auditd_override --verify-disable --IPAddressDeny "any" --IPAddressAllow "192.168.10.1/24" && \
	  [ "$(md5sum "${DESTDIR}"/etc/systemd/system/auditd.service.d/90-linux-infosec-setupper-auditd-firewall.conf | awk '{print $1}')" = 7e6c56977e7177a8fe9bb66adba3ac3b ] ;} || \
    { echo failed test 1; failed="$((++failed))"; }
	{ _mk_systemd_auditd_override --verify-disable --IPAddressDeny "any" --IPAddressAllow "192.168.10.1/24" --IPAddressAllow "192.168.20.1"  && \
	  [ "$(md5sum "${DESTDIR}"/etc/systemd/system/auditd.service.d/90-linux-infosec-setupper-auditd-firewall.conf | awk '{print $1}')" = 27f8c93280d21e8b0d4b399ac234b663 ] ;} || \
    { echo failed test 2; failed="$((++failed))"; }
    _mk_auditd_config --log_group root || { echo failed test 3; failed="$((++failed))"; }
    [ "$(md5sum "${VAR_DIR_AUDIT}/auditd-conf.sh" | awk '{print $1}')" = 650f41086f25b6c0736bdc0323ca6267 ] || { echo failed test 4; failed="$((++failed))"; }
    _mk_auditd_config || { echo failed test 5; failed="$((++failed))"; }
    [ "$(md5sum "${VAR_DIR_AUDIT}/auditd-conf.sh" | awk '{print $1}')" = 650f41086f25b6c0736bdc0323ca6267 ] || { echo failed test 6; failed="$((++failed))"; }
    ! _mk_auditd_config --local_events xuy || { echo failed test 7; failed="$((++failed))"; }
}

_main

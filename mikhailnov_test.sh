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
	  [ "$(md5sum "${DESTDIR}"/etc/systemd/system/auditd.service.d/90-linux-infosec-setupper-auditd-firewall.conf | awk '{print $1}')" = 4088ff9965f0a09f97656646e2f8487a ] ;} || \
    { echo failed test 1; failed="$((++failed))"; }
	{ _mk_systemd_auditd_override --verify-disable --IPAddressDeny "any" --IPAddressAllow "192.168.10.1/24" --IPAddressAllow "192.168.20.1"  && \
	  [ "$(md5sum "${DESTDIR}"/etc/systemd/system/auditd.service.d/90-linux-infosec-setupper-auditd-firewall.conf | awk '{print $1}')" = 328a21120354f2d2ab8888ebffb54fac ] ;} || \
    { echo failed test 1; failed="$((++failed))"; }
}

_main

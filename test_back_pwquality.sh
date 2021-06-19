#!/bin/bash

set -x
set -e
. ./back_pwquality.sh
failed=0

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
	if _mk_pwquality_conf --minclass STRING 1>/dev/null ; then
		echo failed test 1
		failed="$((++failed))"
	fi
	_mk_pwquality_conf --usercheck 1 1>/dev/null || { echo failed test 2 && failed="$((++failed))" ;}
	! _mk_pwquality_conf --enforcing 1 --retry --usersubstr 1>/dev/null || { echo failed test 3 && failed="$((++failed))" ;}
	_mk_pwquality_conf --ucredit -3 || { echo failed test 3 && failed="$((++failed))" ;}
	_mk_pwquality_conf --ucredit 3 || { echo failed test 3 && failed="$((++failed))" ;}
	_mk_pwquality_conf --ucredit +3 || { echo failed test 3 && failed="$((++failed))" ;}
}

_main

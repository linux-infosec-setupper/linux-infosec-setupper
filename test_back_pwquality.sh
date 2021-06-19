#!/bin/bash

failed="${failed:-0}"
set -x
set -e

TESTING=1

. ./common.sh 
. ./back_pwquality.sh

! _mk_pwquality_conf --minclass STRING 1>/dev/null || failed="$((++failed))"
_mk_pwquality_conf --usercheck 1 1>/dev/null || failed="$((++failed))"
! _mk_pwquality_conf --enforcing 1 --retry --usersubstr 1>/dev/null || failed="$((++failed))"

echo "$failed"
exit "$failed"

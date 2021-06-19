#!/bin/bash
set -e

source common.sh

_mk_pwquality_conf() {
	local difok=1 \
	      minlen=8 \
	      dcredit=0 \
	      uncredit=0 \
	      lcredit=0 \
	      ocredit=0 \
	      minclass=0 \
	      maxrepeat=0 \
	      maxsequence=0 \
	      maxclassrepeat=0 \
	      gecoscheck=0 \
	      dictcheck=1 \
	      usercheck=1 \
	      usersubstr=0 \
	      enforcing=1 \
	      badwords \
	      dictpath \
	      retry=1 \
	      enforce_for_root=0 \
	      local_users_only=0
	while [ -n "$1" ]; do
		case "$1" in
			--difok) shift;
				 _check_argument_is_number "$1" "--difok"
		;;
			--minlen) shift;
				  _check_argument_value "$1" "6" "--minlen"
		;;
			--dcredit) shift;
				   _check_argument_is_number "$1" "--dcredit" "-"		   
		;;
		 esac
	 done
}
_mk_pwquality_conf --dcredit -1

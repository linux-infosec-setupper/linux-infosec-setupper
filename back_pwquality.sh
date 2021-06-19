#!/bin/bash
set -e
DESTDIR="${DESTDIR:-}"
PWQUALITY_CONF_FILE="${DESTDIR}/etc/security/pwquality.conf"
INTERNAL_DIR='/var/lib/linux-infosec-setupper'

_check_argument() {
	case "$1" in
	
	if [[ "$1" == [0-9]* ]]; then
		return 0
	else
		printf $"Argument to %s must be a number" "$2"
		return 1
	fi
}

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
				 _check_argument "$1" "--difok"
				 ;;
			--minlen)
		 esac
	 done
 }

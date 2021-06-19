#!/bin/bash
set -e

source common.sh

_mk_pwquality_conf() {
	local failed=0
	local difok=1 \
	      minlen=8 \
	      dcredit=0 \
	      ucredit=0 \
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
				_check_argument_is_number "$1" "--difok" || failed=1
				difok="$1"
				shift
		;;
			--minlen) shift;
				_check_argument_value "$1" "6" "--minlen" || failed=1
				minlen="$1"
				shift
		;;
			--dcredit) shift;
				_check_argument_is_number "$1" "--dcredit" "-" || failed=1
				dcredit="$1"
				shift
		;;
			--ucredit) shift;
				_check_argument_is_number "$1" "--ucredit" "-" || failed=1
				ucredit="$1"
				shift
		;;
			--lcredit) shift;
				_check_argument_is_number "$1" "--lcredit" "-" || failed=1
				lcredit="$1"
				shift
		;;
			--ocredit) shift;
				_check_argument_is_number "$1" "--ocredit" "-" || failed=1
				ocredit="$1"
				shift
		;;
			--minclass) shift;
				_check_argument_is_number "$1" "--minclass" || failed=1
				minclass="$1"
				shift
		;;
			--maxrepeat) shift;
			 	_check_argument_is_number "$1" "--maxrepeat" || failed=1
				maxrepeat="$1"
				shift
		;;
			--maxsequence) shift;
				_check_argument_is_number "$1" "--maxsequence" || failed=1
				maxsequence="$1"
				shift
		;;
			--maxclassrepeat) shift;
				_check_argument_is_number "$1" "--maxclassrepeat" || failed=1
				maxclassrepeat="$1"
		;;
			--gecoscheck) shift;
				_check_argument_is_number "$1" "--gecoscheck" || failed=1
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				geoscheck="$1"
				shift
		;;
			--dictcheck) shift;
				_check_argument_is_number "$1" "--dictcheck" || failed=1
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				dickcheck="$1"
				shift
		;;
			--usercheck) shift;
				_check_argument_is_number "$1" "--usercheck" || failed=1
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				usercheck="$1"
				shift
		;;
			--usersubstr) shift;
				_check_argument_is_number "$1" "--usersubstr" || failed=1
				usersubstr="$1"
				shift
		;;
			--enforcing) shift;
				_check_argument_is_number "$1" "--enforcing" || failed=1
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				enforcing="$1"
				shift
		;;
			--retry) shift;
				_check_argument_is_number "$1" "--retry" || failed=1
				shift
		;;
			--enforce_for_root) shift;
				_check_argument_is_number "$1" "--enforce_for_root" || failed=1
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				enforce_for_root="$1"
				shift
		;;
			--local_users_only) shift;
				_check_argument_is_number "$1" "--local_users_only" || failed=1
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				local_users_only="$1"
				shift
		;;
		esac
	done
	if [ "$failed" != 0 ]; then
		error $"Errors occured when trying to understand how to configure auditd"
		return 1
	fi
cat <<EOF
difok = $difok
minlen = $minlen
dcredit = $dcredit
ucredit = $ucredit
lcredit = $lcredit
ocredit = $ocredit
minclass = $minclass
maxrepeat = $maxrepeat
maxsequence = $maxsequence
maxclassrepeat = $maxclassrepeat
gecoscheck = $gecoscheck
dictcheck = $dictcheck
usercheck = $usercheck
usersubstr = $usersubstr
enforcing = $enforcing
retry = $retry
EOF
if [ "$enforce_for_root" = 1 ]; then echo "enforce_for_root"; fi
if [ "$local_users_only" = 1 ]; then echo "local_users_only"; fi
}

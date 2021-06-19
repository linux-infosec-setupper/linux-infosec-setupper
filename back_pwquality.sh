#!/bin/bash
set -e

source common.sh

_mk_pwquality_conf() {
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
				_check_argument_is_number "$1" "--difok"
				difok="$1"
				shift
		;;
			--minlen) shift;
				_check_argument_value "$1" "6" "--minlen"
				minlen="$1"
				shift
		;;
			--dcredit) shift;
				_check_argument_is_number "$1" "--dcredit" "-"
				dcredit="$1"
				shift
		;;
			--ucredit) shift;
				_check_argument_is_number "$1" "--ucredit" "-"
				ucredit="$1"
				shift
		;;
			--lcredit) shift;
				_check_argument_is_number "$1" "--lcredit" "-"
				lcredit="$1"
				shift
		;;
			--ocredit) shift;
				_check_argument_is_number "$1" "--ocredit" "-"
				ocredit="$1"
				shift
		;;
			--minclass) shift;
				_check_argument_is_number "$1" "--minclass"
				minclass="$1"
				shift
		;;
			--maxrepeat) shift;
			 	_check_argument_is_number "$1" "--maxrepeat"
				maxrepeat="$1"
				shift
		;;
			--maxsequence) shift;
				_check_argument_is_number "$1" "--maxsequence"
				maxsequence="$1"
				shift
		;;
			--maxclassrepeat) shift;
				_check_argument_is_number "$1" "--maxclassrepeat"
				maxclassrepeat="$1"
		;;
			--gecoscheck) shift;
				_check_argument_is_number "$1" "--gecoscheck"
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				geoscheck="$1"
				shift
		;;
			--dictcheck) shift;
				_check_argument_is_number "$1" "--dictcheck"
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				dickcheck="$1"
				shift
		;;
			--usercheck) shift;
				echo 1
				_check_argument_is_number "$1" "--usercheck"
				echo 2
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				echo 3
				usercheck="$1"
				echo 4
				shift
		;;
			--usersubstr) shift;
				_check_argument_is_number "$1" "--usersubstr"
				usersubstr="$1"
				shift
		;;
			--enforcing) shift;
				_check_argument_is_number "$1" "--enforcing"
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				enforcing="$1"
				shift
		;;
			--retry) shift;
				_check_argument_is_number "$1" "--retry"
				shift
		;;
			--enforce_for_root) shift;
				_check_argument_is_number "$1" "--enforce_for_root"
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				enforce_for_root="$1"
				shift
		;;
			--local_users_only) shift;
				_check_argument_is_number "$1" "--local_users_only"
				[[ "$1" =~ (0|1) ]] || error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"
				local_users_only="$1"
				shift
		;;
		esac
	done
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
[ "$enforce_for_root" == 1 ] && echo "enforce_for_root"
[ "$local_users_only" == 1 ] && echo "local_users_only"
}

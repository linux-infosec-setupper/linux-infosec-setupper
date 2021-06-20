#!/bin/bash
set -e

# detect running from git tree
if [ -f ./common.sh ] && [ -f "$0" ]
then
	source common.sh
else
	source /usr/share/linux-infosec-setupper/common.sh
fi
source "${SHARE_DIR_PWQUALITY}/parse_pwquality.sh"

_mk_pwquality_conf() {
local failed=0
while read -r line; do local "$line" || { error $"Unable to parse /etc/security/pwquality.conf correctly; execute \n%s" "rm ${VAR_DIR_PWQUALITY}/pw_changed"; exit 1; }; done < <(_pw_parse_conf)
	while [ -n "$1" ]; do
		case "$1" in
			--difok) shift;
				_check_argument_is_number "$1" "--difok" || failed=1
				difok="$1"
		;;
			--minlen) shift;
				_check_argument_value "$1" "6" "--minlen" || failed=1
				minlen="$1"
		;;
			--dcredit) shift;
				_check_argument_is_number "$1" "--dcredit" "-" || failed=1
				dcredit="$1"
		;;
			--ucredit) shift;
				_check_argument_is_number "$1" "--ucredit" "-" || failed=1
				ucredit="$1"
		;;
			--lcredit) shift;
				_check_argument_is_number "$1" "--lcredit" "-" || failed=1
				lcredit="$1"
		;;
			--ocredit) shift;
				_check_argument_is_number "$1" "--ocredit" "-" || failed=1
				ocredit="$1"
		;;
			--minclass) shift;
				_check_argument_is_number "$1" "--minclass" || failed=1
				minclass="$1"
		;;
			--maxrepeat) shift;
			 	_check_argument_is_number "$1" "--maxrepeat" || failed=1
				maxrepeat="$1"
		;;
			--maxsequence) shift;
				_check_argument_is_number "$1" "--maxsequence" || failed=1
				maxsequence="$1"
		;;
			--maxclassrepeat) shift;
				_check_argument_is_number "$1" "--maxclassrepeat" || failed=1
				maxclassrepeat="$1"
		;;
			--gecoscheck) shift;
				_check_argument_is_number "$1" "--gecoscheck" || failed=1
				[[ "$1" =~ (0|1) ]] || { error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"; failed=1; }
				geoscheck="$1"
		;;
			--dictcheck) shift;
				_check_argument_is_number "$1" "--dictcheck" || failed=1
				[[ "$1" =~ (0|1) ]] || { error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"; failed=1; }
				dictcheck="$1"
		;;
			--usercheck) shift;
				_check_argument_is_number "$1" "--usercheck" || failed=1
				[[ "$1" =~ (0|1) ]] || { error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"; failed=1; }
				usercheck="$1"
		;;
			--usersubstr) shift;
				_check_argument_is_number "$1" "--usersubstr" || failed=1
				usersubstr="$1"
		;;
			--enforcing) shift;
				_check_argument_is_number "$1" "--enforcing" || failed=1
				[[ "$1" =~ (0|1) ]] || { error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"; failed=1; }
				enforcing="$1"
		;;
			--retry) shift;
				_check_argument_is_number "$1" "--retry" || failed=1
				retry="$1"
		;;
			--enforce_for_root) shift;
				_check_argument_is_number "$1" "--enforce_for_root" || failed=1
				[[ "$1" =~ (0|1) ]] || { error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"; failed=1; }
				enforce_for_root="$1"
		;;
			--local_users_only) shift;
				_check_argument_is_number "$1" "--local_users_only" || failed=1
				[[ "$1" =~ (0|1) ]] || { error $"The received parameters are not correct. Expected %s, received %s" $"0 or 1" "$1"; failed=1; }
				local_users_only="$1"
		;;
		esac
	shift
	done
	if [ "$failed" != 0 ]; then
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
# These parameters do not have keys (numbers after the = sign), so we work with them in a different way
if [ "$enforce_for_root" == 1 ]; then echo "enforce_for_root"; fi
if [ "$local_users_only" == 1 ]; then echo "local_users_only"; fi
}

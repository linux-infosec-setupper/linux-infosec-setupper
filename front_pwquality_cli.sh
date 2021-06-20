#!/bin/bash

source "${DESTDIR}/usr/share/linux-infosec-setupper/common.sh"

# Check whether we are running the script for the first time
# Since the config may be standard from the package, it may not be parsed correctly.
# We write our default config instead of the original one, so that the parsing works correctly
if ! [[ -f "${VAR_DIR_PWQUALITY}/pw_changed" ]]; then
	cat "${SHARE_DIR_PWQUALITY}/pw_default" > "${DESTDIR}/etc/security/pwquality.conf" || { error $"Unable to write to file %s" "${DESTDIR}/etc/security/pwquality.conf"; exit 1; }
	install -D -m 444 /dev/null "${VAR_DIR_PWQUALITY}/pw_changed" || { error $"Unable to write to file %s" "${VAR_DIR_PWQUALITY}/pw_changed"; exit 1; }
fi

source "${SHARE_DIR_PWQUALITY}/parse_pwquality.sh"
source "${SHARE_DIR_PWQUALITY}/back_pwquality.sh"

while read -r line; do declare "$line" || { error $"Unable to parse /etc/security/pwquality.conf correctly; execute \n%s" "rm ${VAR_DIR_PWQUALITY}/pw_changed"; exit 1; }; done < <(_pw_parse_conf)

PWQUALITY_FRONT=1
failed=0
_args="$(echo "$@" | sed 's/\(d \|-d \)/--difok /
			 ;s/\(m \|-m \)/--minlen /
			 ;s/\(dc \|-dc \)/--dcredit /
			 ;s/\(uc \|-uc \)/--ucredit /
			 ;s/\(lc \|-lc \)/--lcredit /
			 ;s/\(oc \|-oc \)/--ocredit /
			 ;s/\(geco \|-geco \)/--gecoscheck /
			 ;s/\(e \|-e \)/--enforcing /
			 ;s/\(r \|-r \)/--retry /')"

if [ -z "$1" ]; then
	error $"No arguments specified"
	exit 1
fi

case "$1" in -h|--help|h|help)
echo $"Usage: #NAME# --[OPTIONS...]"
echo $"  example: #NAME# --difok 6"
echo $"  example: #NAME# d 6"
echo $"#NAME# allows you to manage the file configuration for pwquality in the cli option. A GUI version is also available: #NAME2#"
echo ''
echo $"  Options:"
echo $"    d,  difok             Number of characters in the new password that must not be present in the old password"
echo $"    m,  minlen            Minimum acceptable size for the new password"
echo $"    dc, dcredit           The maximum credit for having digits in the new password"
echo $"    uc, ucredit           The maximum credit for having uppercase characters in the new password"
echo $"    lc, lcredit           The maximum credit for having lowercase characters in the new password"
echo $"    oc, ocredit           The maximum credit for having other characters in the new password"
echo $"        minclass          The minimum number of required classes of characters for the new password"
echo $"        maxrepeat         The maximum number of allowed same consecutive characters in the new password"
echo $"        maxsequence       The maximum length of monotonic character sequences in the new password"
echo $"        maxclassrepeat    The maximum number of allowed consecutive characters of the same class in the new password"
echo $"    geco, gecoscheck      Check whether the words longer than 3 characters from the GECOS field of the user's passwd(5) entry are contained in the new password"
echo $"        dictcheck         Check whether the password (with possible modifications) matches a word in a dictionary"
echo $"        usercheck         Check whether the password (with possible modifications) contains the user name in some form"
echo $"        usersubstr        Check whether the password contains a substring of at least N length in some form"
echo $"        enforcing         Reject the password if it fails the checks, otherwise only print the warning"
echo $"        retry             Prompt user at most N times before returning with error"
echo $"        enforce_for_root  The module will return error on failed check even if the user changing the password is root"
echo $"        local_users_only  The module will not test the password quality for users that are not present in the /etc/passwd file"
echo ''
exit 0
	;;
		esac
	shift
_number=1
while read -r args; do
	if [[ $(( _number % 2 )) = 1 ]]; then
	case "$args" in
		--*) : ;;
		-*) args="-$args" ;;
		*) args="--$args" ;;
	esac
	fi
	arg_line+=("$args")
	((_number++))
done < <(echo -e "${_args// /\\n}")
_mk_pwquality_conf ${arg_line[@]} > "${DESTDIR}/etc/security/pwquality.conf" || { error $"Unable to write to file %s" "${DESTDIR}/etc/security/pwquality.conf"; exit 1; }

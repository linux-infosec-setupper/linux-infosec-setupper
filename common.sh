# prefix for testing
DESTDIR="${DESTDIR:-}"
PWQUALITY_CONF_FILE="${DESTDIR}/etc/security/pwquality.conf"
VAR_DIR_ROOT="${DESTDIR}/var/lib/linux-infosec-setupper"
VAR_DIR_PWQUALITY="${VAR_DIR_ROOT}/pwquality"
VAR_DIR_AUDIT="${VAR_DIR_ROOT}/audit"
SHARE_DIR_ROOT="${DESTDIR}/usr/share/linux-infosec-setupper"
SHARE_DIR_PWQUALITY="${SHARE_DIR_ROOT}/pwquality"
SHARE_DIR_AUDIT="${SHARE_DIR_ROOT}/audit"
# /etc/audit/audit.rules is generated automatically from /etc/audit/rules.d/*,
# do not edit it; also do not edit any other files, work only with ours,
# assume that there are no other configs or they have lower priority
AUDIT_RULES_FILE="${DESTDIR}/etc/audit/rules.d/90-linux-infosec-setupper.rules"
AUDIT_DAEMON_CONFIG="${DESTDIR}/etc/audit/auditd.conf"
AUDIT_DAEMON_SYSTEMD_OVERRIDE="${DESTDIR}/etc/systemd/system/auditd.service.d/90-linux-infosec-setupper-auditd-firewall.conf"
# validate email, https://stackoverflow.com/a/2138832, https://stackoverflow.com/a/41192733
REGEX_EMAIL="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

error() {
	printf "$@" 1>&2
	echo '' 1>&2
}

# $1 - value
# $2 - param name
# (optional) $3 - anything, trigger check for non-negative
_check_argument_is_number() {
	if [[ "$1" == [0-9]* ]]; then
		return 0
	else
		if [ -n "$3" ]; then
			grep -Exq -- "(\-|\+)[0-9]*" <<< "$1" && return 0
		fi
		error $"Argument to %s must be a number" "$2"
		return 1
	fi
}

# $1 - value
# $2 - param name
_check_argument_value() {
	if (( "$1" < "$2" )); then
		error $"Argument to %s must be greater than %s" "$2" "$3"
		return 1
	else
		return 0
	fi
}

# $1 - value
# $2 - param name
_check_argument_is_string() {
	if [[ "$1" == *[[:blank:]]* ]]; then
		error $"Argument to %s must be a string without spaces"  "$2"
		return 1
	else
		return 0
	fi
}

# $1 - value
# $2 - param name
_check_argument_is_boolean(){
	case "$1" in
		"yes" ) return 0 ;;
		"no" ) return 0 ;;
		"" )
			error $"Value of %s is empty, set yes or no" "$2"
			return 1
		;;
		* )
			error $"String %s is not a boolean, set yes or no" "$1"
			return 1
		;;
	esac
}

# $1 - value
# $2 - param name
_check_argument_is_non_negative_number(){
	# 2>/dev/null to avoid odd output if $1 is not a number
	if ! test "$1" -lt 0 2>/dev/null; then
		error $"Value of %s must be a non-negative number" "$2"
		return 1
	fi
}

_validate_email(){
	if ! [[ "$1" =~ ${regex_email} ]] ; then
		error $"%s is not a correct email" "$1"
		return 1
	fi
}

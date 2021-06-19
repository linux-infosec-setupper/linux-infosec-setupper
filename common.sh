# prefix for testing
DESTDIR="${DESTDIR:-}"
PWQUALITY_CONF_FILE="${DESTDIR}etc/security/pwquality.conf"
INTERNAL_DIR="${DESTDIR}var/lib/linux-infosec-setupper"
# /etc/audit/audit.rules is generated automatically from /etc/audit/rules.d/*,
# do not edit it; also do not edit any other files, work only with ours,
# assume that there are no other configs or they have lower priority
AUDIT_RULES_FILE=${DESTDIR}etc/audit/rules.d/90-linux-infosec-setupper.rules
AUDIT_DAEMON_CONFIG=${DESTDIR}etc/audit/auditd.conf


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
		;;
		* )
			error $"String %s is not a boolean, set yes or no" "$1"
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

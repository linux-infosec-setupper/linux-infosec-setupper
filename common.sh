# prefix for testing
DESTDIR="${DESTDIR:-}"
PWQUALITY_CONF_FILE="${DESTDIR}etc/security/pwquality.conf"
INTERNAL_DIR="${DESTDIR}var/lib/linux-infosec-setupper"
# /etc/audit/audit.rules is generated automatically from /etc/audit/rules.d/*,
# do not edit it; also do not edit any other files, work only with ours,
# assume that there are no other configs or they have lower priority
AUDIT_RULES_FILE=${DESTDIR}etc/audit/rules.d/90-linux-infosec-setupper.rules
AUDIT_DAEMON_CONFIG=${DESTDIR}etc/audit/auditd.conf

_check_argument() {
	case "$1" in
	
	if [[ "$1" == [0-9]* ]]; then
		return 0
	else
		printf $"Argument to %s must be a number" "$2"
		return 1
	fi
}

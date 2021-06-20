#!/bin/bash
set -e

# detect running from git tree
if [ -f ./common.sh ] && [ -f "$0" ]
then
	source common.sh
else
	source /usr/share/linux-infosec-setupper/common.sh
fi

# make temporary files not accessible to non-root
# like auditd config is not accessible
umask 0077

# $1 - action
# $2 - param name
_audit_action_config(){
	local l_failed=0
	case "$1" in
		ignore ) : ;;
		syslog ) : ;;
		rotate ) : ;;
		email ) : ;;
		suspend ) : ;;
		single ) : ;;
		halt ) : ;;
		exec* )
			if [[ "$1" =~ ^exec([[:space:]])*$ ]]; then
				error $"Entered %s=exec /path/to/script does not contain a path to script" "$2"
				l_failed=1
			elif [ "$(echo "$1" | tr '[:space:]' '\n' | wc -l)" != 2 ]; then
				error $"%s=exec* can have only one agrument — path to script, example: %s=exec /path/to/script" "$2" "$2"
				l_failed=1
			else
				local path_to_script="$(echo "$1" | awk '{print $2}')"
				if ! test -x "$path_to_script"; then
					error $"Script %s is not executable" "$path_to_script"
					l_failed=1
				fi
			fi
		;;
		* )
			error $"Possible values of %s are: %s" "exec" "ignore, syslog, rotate, email, exec /path/to/script, suspend, single, halt"
			l_failed=1
		;;
	esac
	return "$l_failed"
}

_mk_systemd_auditd_override(){
	local do_verify=1
	if [ -z "$DESTDIR" ]; then do_verify=0; fi
	# auditd.service: Command /sbin/auditd is not executable: Permission denied
	if [ "$(id -u)" -ne 0 ] ; then do_verify=0; fi
	# --IPAddressAllow=xxx --IPAddressDeny=xxx may be specified multiple times
	local IPAddressAllow=""
	local IPAddressDeny=""
	while [ -n "$1" ]
	do
		case "$1" in
			"--verify-disable" )
				do_verify=0
			;;
			"--IPAddressAllow" )
				shift
				IPAddressAllow="${IPAddressAllow} $1"
			;;
			"--IPAddressDeny" )
				shift
				IPAddressDeny="${IPAddressDeny} $1"
			;;
		esac
		shift
	done
	local systemd_override_dir="$(dirname "$AUDIT_DAEMON_SYSTEMD_OVERRIDE")"
	if ! mkdir -p "$systemd_override_dir" ; then
		error $"Error creating directory %s" "$systemd_override_dir"
		return 1
	fi
	cat > "$AUDIT_DAEMON_SYSTEMD_OVERRIDE" << EOF
[Unit]
# change Before and After according to comments in auditd.service
After=
After=network-online.target local-fs.target systemd-tmpfiles-setup.service
Before=
Before=shutdown.target
[Service]
$(for i in $IPAddressAllow
do
	echo "IPAddressAllow=$i"
done)
$(for i in $IPAddressDeny
do
	echo "IPAddressDeny=$i"
done)
EOF
	systemd_allowed_ip_list="$IPAddressAllow"
	systemd_denied_ip_list="$IPAddressDeny"
	# Make it work inside e.g. Anaconda module where $DESTDIR is not empty
	# probably by copying the file to the root of the LiveCD.
	# Detection of being run from Anaconda here is a prototype.
	if [ "${I_AM_ANACONDA:-0}" != 0 ]; then
		local cp_dst="$(echo "$AUDIT_DAEMON_SYSTEMD_OVERRIDE" | sed -e "s,^${DESTDIR},,")"
		if cp "$AUDIT_DAEMON_SYSTEMD_OVERRIDE" "$cp_dst"
		then
			do_verify=1
		else
			error $"Error copying systemd override file %s to %s" "$AUDIT_DAEMON_SYSTEMD_OVERRIDE" "$cp_dst"
			return 1
		fi
	fi
	if [ "$do_verify" = 1 ]; then
		local systemd_analyze_result="$(systemd-analyze verify auditd.service 2>&1)"
		if [ $? != 0 ]; then
			error $"Systemd unit file auditd.service with setted up packet filtering has not passed verification!"
			error $"The error was:"
			error "$systemd_analyze_result"
		fi
	fi
}

# can be used to reset variables to default values after loading previously setted up ones
_audit_variables(){
	local_events="yes"
	log_file="/var/log/audit/audit.log"
	write_logs="yes"
	log_format="ENRICHED"
	log_group="root"
	priority_boost="4"
	flush="incremental_async"
	freq=""
	max_log_fileaction="rotate"
	num_logs=3
	# default is lossy, but let's better prevent potential loss of audit events
	disp_qos="lossless"
	# XXX why does audispd not exist in Fedora and Red OS 7.3? It exists in rosa2019.1
	dispatcher=""
	distribute_network="no"
	# default is "none", but let's make logs better parsable and readable, e.g. on syslog server
	name_format="hostname"
	name=""
	max_log_file=8
	action_mail_acct=""
	space_left="10%"
	# log if free space is low but still enough,
	# Zabbix etc. can be used to make notification in such case
	space_left_action="syslog"
	# poweroff system if logs cannot be stored according to configured policy (paranoidal)
	disk_full_action="halt"
	disk_error_action="halt"
	tcp_listen_port=""
	tcp_max_per_addr=""
	systemd_allowed_ip_list="1 1"
	systemd_denied_ip_list="2 2"
}

_mk_auditd_config(){
	_audit_variables
	local failed=0
	# Bellow we go through all cli options and print all errors,
	# not failing on the first one, showing all errors to the user
	while [ -n "$1" ]
	do
		case "$1" in
			"--local_events" ) shift;
				_check_argument_is_boolean "$1" "local_events" || failed=1
				local_events="$1"
			;;
			# We recommend using default /var/log/audit/audit.log to avoid mess
			# with SELinux, log rotation (auditd rotates the log by itself by default
			# but admins/distrobuilders may additionally setup logrotate.d
			"--log_file" ) shift;
				if _check_argument_is_string "$1" "log_file"
				then
					local dir="$(dirname "$1")"
					if ! test -w "$dir" ; then
						error $"Directory %s does not exist" "$dir"
						failed=1
					fi
					log_file="$1"
				else
					failed=1
				fi
			;;
			"--write_logs" ) shift;
				_check_argument_is_boolean "$1" "write_logs"  || failed=1
				write_logs="$1"
			;;
			"--log_format" ) shift;
				if ! { [ "$1" = "ENRICHED" ] || [ "$1" = "RAW" ] ;}; then
					error $"Value of %s must be %s or %s" "log_format" "ENRICHED" "RAW"
					failed=1
				fi
				log_format="$1"
			;;
			"--log_group" ) shift;
				_check_argument_is_string "$1" "log_group" || failed=1
				# We could try to resolve the group here, but NSS (/etc/nsswitch.conf) may be
				# not yet configured or a connection to a domain (FreeIPA, LDAP, AD etc.)
				# may be not yet estabilished, e.g. in a chroot when being run via Anaconda installer,
				# so such a check does not make sense
				log_group="$1"
			;;
			"--priority_boost" ) shift;
				_check_argument_is_non_negative_number "$1" "priority_boost" || failed=1
				priority_boost="$1"
			;;
			"--flush" ) shift;
				_check_argument_is_string "$1" "flush" || failed=1
				case "$1" in
					none ) : ;;
					incremental ) : ;;
					incremental_async ) : ;;
					data ) : ;;
					sync ) : ;;
					* )
						error $"Possible values of %s are: %s" "flush" "none, incremental, incremental_async, data, sync"
						failed=1
					;;
				esac
				flush="$1"
			;;
			"--freq" ) shift;
				if [ "$flush" = "incremental_async" ]; then
					_check_argument_is_non_negative_number "$1" "freq" || failed=1
					freq="$1"
				else
					error $"Parameter %s makes sense only when %s" "freq" "flush=incremental_async"
					failed=1
				fi
			;;
			"--max_log_fileaction" ) shift;
				if _check_argument_is_string "$1" "max_log_file_action"
				then
					case "$1" in
						ignore ) : ;;
						syslog ) : ;;
						suspend ) : ;;
						rotate ) : ;;
						keep_logs ) : ;;
						* )
							error $"Possible values of %s are: %s" "max_log_file_action" "ignore, syslog, suspend, rotate, keep_logs"
							failed=1
						;;
					esac
					max_log_fileaction="$1"
				else
					failed=1
				fi
			;;
			"--num_logs" ) shift;
				if [ "$max_log_fileaction" != "rotate" ]
				then
					error $"Parameter %s makes sense only when %s" "num_logs" "max_log_file_action=rotate"
					failed=1
				else
					_check_argument_is_non_negative_number "$1" "num_logs" || failed=1
					num_logs="$1"
				fi
			;;
			"--disp_qos" ) shift;
				if _check_argument_is_string "$1" "disp_qos"
				then
					case "$1" in
						lossy ) : ;;
						lossless ) : ;;
						* )
							error $"Possible values of %s are: %s" "disp_qos" "lossy, lossless"
							failed=1
						;;
					esac
					disp_qos="$1"
				else
					failed=1
				fi
			;;
			"--dispatcher" ) shift;
				if _check_argument_is_string "$1" "dispatcher"
				then
					if ! test -x "$1" ; then
						error $"File %s does not exist or is not executable, so %s cannot be set as a dispatcher executable" "$1" "$1"
						failed=1
					fi
					dispatcher="$1"
				else
					failed=1
				fi
			;;
			"--distribute_network" ) shift;
				if [ -n "$dispatcher" ]
				then
					_check_argument_is_boolean "$1" "distribute_network" || failed=1
				else
					error $"%s requires %s to be configured" "distribute_network" "dispatcher"
					failed=1
				fi
				distribute_network="$1"
			;;	
			"--name_format" ) shift;
				if _check_argument_is_string "$1" "name_format"
				then
					case "$1" in
						none ) : ;;
						hostname ) : ;;
						fqd ) : ;;
						numeric ) : ;;
						user ) : ;;
						* )
							error $"Possible values of %s are: %s" "disp_qos" "none, hostname, fqd, numeric, user"
							failed=1
						;;
					esac
					name_format="$1"
				else
					failed=1
				fi
			;;
			"--name" ) shift;
				if [ "$name_format" != "user" ]
				then
					error $"Parameter %s makes sense only when %s" "name" "name_format != user"
					failed=1
				else
					name="$1"
				fi
			;;
			"--max_log_file" ) shift;
				_check_argument_is_non_negative_number "$1" "max_log_file" || failed=1
				max_log_file="$1"
			;;
			"--action_mail_acct" ) shift;
				_validate_email "$1" || failed=1
				action_mail_acct="$1"
			;;
			"--space_left" ) shift;
				local tmp_space_left="$1"
				# last character of string (https://stackoverflow.com/a/21635778)
				if [ "${tmp_space_left: -1}" = "%" ]; then
					tmp_space_left="$(echo "$tmp_space_left" | sed -e 's,%$,,')"
					_check_argument_is_non_negative_number "$tmp_space_left" "space_left" || failed=1
				fi
				_check_argument_is_non_negative_number "$space_left" "space_left" || failed=1
				space_left="$1"
				unset tmp_space_left
			;;
			"--space_left_action" ) shift;
				if ! _audit_action_config "$1" "space_left_action" ; then
					failed=1
				fi
				space_left_action="$1"
			;;
			"--disk_full_action" ) shift;
				if ! _audit_action_config "$1" "disk_full_action" ; then
					failed=1
				fi
				disk_full_action="$1"
			;;
			"--disk_error_action" ) shift;
				if ! _audit_action_config "$1" "disk_error_action" ; then
					failed=1
				fi
				disk_error_action="$1"
			;;
			# TODO: admin_space_left
			# TODO: admin_space_left_action
			# + compare with space_left, must be less according to the manual

			# auditd can use tcp_wrappers, but it is a vulnerable, depreceated and not secure mechanism;
			# we will not configure tcp_wrappers, instead we will configure list of allowed and disallowed
			# IP addresses via systemd (http://0pointer.net/blog/ip-accounting-and-access-lists-with-systemd.html)
			# Working as an audit server (listening a port) is disabled by default
			"--tcp_listen_port" ) shift;
				if _check_argument_is_non_negative_number "$1" "tcp_listen_port"
				then
					# 1..65535
					if [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
						error $"%s must be an integer between %s and %s" "tcp_listen_port" 1 65535
						failed=1
					fi
				else
					failed=1
				fi
				tcp_listen_port="$1"
			;;
			"--tcp_max_per_addr" ) shift;
				if _check_argument_is_non_negative_number "$1" "tcp_max_per_addr"
				then
					# 1..65535
					if [ "$1" -lt 1 ] || [ "$1" -gt 1024 ]; then
						error $"%s must be an integer between %s and %s" "tcp_listen_port" 1 1024
						failed=1
					fi
				else
					failed=1
				fi
				tcp_max_per_addr="$1"
			;;
			# TODO: tcp_client_ports
			# TODO: tcp_client_max_idle

			# TODO: kerberos authentication against a Kerberos/Samba/FreeIPA server
			# https://listman.redhat.com/archives/linux-audit/2019-April/msg00110.html

			"--systemd-firewalling-params" ) shift;
				_mk_systemd_auditd_override $*
			;;
		esac
		shift
	done
	if [ "$failed" != 0 ]; then
		error $"Errors occured when trying to understand how to configure auditd"
		return 1
	fi
	if ! mkdir -p "${VAR_DIR_AUDIT}" ; then
		error $"Error creating directory %s" "$config_dir"
		return 1
	fi
	# can be sourced from GUI to load previous settings
	cat > "${VAR_DIR_AUDIT}/auditd-conf.sh" << EOF
# Generated by linux-infosec-setupper
local_events="$local_events"
log_file="$log_file"
write_logs="$write_logs"
log_format="$log_format"
log_group="$log_group"
priority_boost="$priority_boost"
flush="$flush"
freq="$freq"
max_log_fileaction="$max_log_fileaction"
num_logs="$num_logs"
disp_qos="$disp_qos"
dispatcher="$dispatcher"
distribute_network="$distribute_network"
name_format="$name_format"
name="$name"
max_log_file="$max_log_file"
action_mail_acct="$action_mail_acct"
space_left="$space_left"
space_left_action="$space_left_action"
disk_full_action="$disk_full_action"
disk_error_action="$disk_error_action"
tcp_listen_port="$tcp_listen_port"
tcp_max_per_addr="$tcp_max_per_addr"
systemd_allowed_ip_list="$systemd_allowed_ip_list"
systemd_denied_ip_list="$systemd_denied_ip_list"
EOF
}

_write_auditd_config(){
	local config_dir="$(dirname "$AUDIT_DAEMON_CONFIG")"
	if ! mkdir -p "$config_dir" ; then
		error $"Error creating directory %s" "$config_dir"
		return 1
	fi
	if ! sed "${VAR_DIR_AUDIT}/auditd-conf.sh" -e '/^systemd_/d' -e 's,=, = ,' -e 's,",,g' -e '/= $/d' > "$AUDIT_DAEMON_CONFIG" ; then
		error $"Error writing auditd config file %s" "$AUDIT_DAEMON_CONFIG"
	fi
	# auditd.service cannot be restarted, a reboot is required
	echo $"Reboot to apply changes to auditd config"
}

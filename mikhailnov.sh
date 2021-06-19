#!/bin/bash
set -e
. common.sh

_is_auditd_enabled(){
	# may add additional checks later
	systemctl is-active -q autitd
}

# $1 - value
# $2 - param name
_auditd_conf_is_boolean(){
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
_auditd_conf_is_non_negative_number(){
	# 2>/dev/null to avoid odd output if $1 is not a number
	if ! test "$1" -lt 0 2>/dev/null; then
		error $"Value of %s must be a non-negative number" "$2"
		return 1
	fi
}

_mk_auditd_config(){
	local failed=0
	local local_events="yes"
	local log_file="/var/log/audit/audit.log"
	local write_logs="yes"
	local log_format="ENRICHED"
	local log_group="root"
	local priority_boost="4"
	local flush="incremental_async"
	local freq=""
	local max_log_fileaction="rotate"
	local num_logs=3
	# default is lossy, but let's better prevent potential loss of audit events
	local disp_qos="lossless"
	# XXX why does audispd not exist in Fedora and Red OS 7.3? It exists in rosa2019.1
	local dispatcher=""
	# default is "none", but let's make logs better parsable and readable, e.g. on syslog server
	local name_format="hostname"
	# Bellow we go through all cli options and print all errors,
	# not failing on the first one, showing all errors to the user
	while [ -n "$1" ]
	do
		case "$1" in
			"--local_events" )
				_auditd_conf_is_boolean "$1" "local_events" || failed=1
				local_events="$1"
				shift
			;;
			# We recommend using default /var/log/audit/audit.log to avoid mess
			# with SELinux, log rotation (auditd rotates the log by itself by default
			# but admins/distrobuilders may additionally setup logrotate.d
			"--log_file" )
				if _check_argument_is_string "$1" "log_file"
				then
					local dir="$(dirname "$1")"
					if ! test -w "$dir" ; then
						error $"Directory %s does not exist" "$dir"
						failed=1
					fi
					log_file="$1"
					shift
				else
					failed=1
				fi
			;;
			"--write_logs" )
				_auditd_conf_is_boolean "$1" "write_logs"  || failed=1
				write_logs="$1"
				shift
			;;
			"--log_format" )
				if ! { [ "$1" = "ENRICHED" ] || [ "$1" = "RAW" ] ;}; then
					error $"Value of %s must be %s or %s" "log_format" "ENRICHED" "RAW"
					failed=1
				fi
				log_format="$1"
				shift
			;;
			"--log_group" )
				_check_argument_is_string "$1" "log_group" || failed=1
				# We could try to resolve the group here, but NSS (/etc/nsswitch.conf) may be
				# not yet configured or a connection to a domain (FreeIPA, LDAP, AD etc.)
				# may be not yet estabilished, e.g. in a chroot when being run via Anaconda installer,
				# so such a check does not make sense
				log_group="$1"
				shift
			;;
			"--priority_boost" )
				_auditd_conf_is_non_negative_number "$1" "priority_boost" || failed=1
				priority_boost="$1"
				shift
			;;
			"--flush" )
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
				shift
			;;
			"--freq" )
				if [ "$flush" = "incremental_async" ]; then
					_auditd_conf_is_non_negative_number "$1" "freq" || failed=1
					freq="$1"
					shift
				else
					error $"Parameter %s makes sense only when %s" "freq" "flush=incremental_async"
					failed=1
				fi
			;;
			"--max_log_fileaction" )
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
					shift
				else
					failed=1
				fi
			;;
			"--num_logs" )
				if [ "$max_log_fileaction" != "rotate" ]
				then
					error $"Parameter %s makes sense only when %s" "num_logs" "max_log_file_action=rotate"
					failed=1
				else
					_auditd_conf_is_non_negative_number "$1" "num_logs" || failed=1
					num_logs="$1"
					shift
				fi
			;;
			"--disp_qos" )
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
					shift
				else
					failed=1
				fi
			;;
			"--dispatcher" )
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
			"--name_format" )
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
					shift
				else
					failed=1
				fi
			;;

		esac
		if [ "$failed" != 0 ]; then
			error $"Errors occured when trying to understand how to configure auditd"
			return 1
		fi
	done
}

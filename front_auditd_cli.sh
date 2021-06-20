#!/bin/bash
set -e

# detect running from git tree
if [ -f ./common.sh ] && [ -f "$0" ]
then
	source common.sh
	source back_auditd.sh
else
	source /usr/share/linux-infosec-setupper/common.sh
	source "${SHARE_DIR_PWQUALITY}/back_auditd.sh"
fi

_audit_variables

_echo_help(){
	_echo $"This is generator of auditd config"
	_echo $"Run as: %s [--parameter value] [--parameter value]" "$0"
	_echo $"Supported parameters of auditd and their default values are:"
	cat << EOF
--local_events "$local_events"
--log_file "$log_file"
--write_logs "$write_logs"
--log_format "$log_format"
--log_group "$log_group"
--priority_boost "$priority_boost"
--flush "$flush"
--freq "$freq"
--max_log_fileaction "$max_log_fileaction"
--num_logs "$num_logs"
--disp_qos "$disp_qos"
--dispatcher "$dispatcher"
--distribute_network "$distribute_network"
--name_format "$name_format"
--name "$name"
--max_log_file "$max_log_file"
--action_mail_acct "$action_mail_acct"
--space_left "$space_left"
--space_left_action "$space_left_action"
--disk_full_action "$disk_full_action"
--disk_error_action "$disk_error_action"
--tcp_listen_port "$tcp_listen_port"
--tcp_max_per_addr "$tcp_max_per_addr"
EOF
}

_main(){
	if [[ "$@" =~ (\-\-help|\-h)($|[[:space:]]) ]]; then
		_echo_help
		exit 0
	fi
	if [ -z "$(echo "$@")" ]; then
		_echo_help
		exit 1
	fi
	_mk_auditd_config $@
	_write_auditd_config
}

_main $@

# Generated by linux-infosec-setupper
local_events="yes"
log_file="/var/log/audit/audit.log"
write_logs="yes"
log_format="ENRICHED"
log_group="root"
priority_boost="4"
flush="incremental_async"
freq=""
max_log_fileaction="rotate"
num_logs="3"
disp_qos="lossless"
dispatcher=""
distribute_network="no"
name_format="hostname"
name=""
max_log_file="8"
action_mail_acct=""
space_left="10%"
space_left_action="syslog"
disk_full_action="halt"
disk_error_action="halt"
tcp_listen_port=""
tcp_max_per_addr=""
systemd_allowed_ip_list=""
systemd_denied_ip_list=""

#!/bin/bash

set -e

# detect running from git tree
if [ -f ./common.sh ] && [ -f "$0" ]
then
	source common.sh
	source back_auditd.sh
else
	source /usr/share/linux-infosec-setupper/common.sh
	source "${SHARE_DIR_AUDIT}/back_auditd.sh"
fi

if ! [ -f "${VAR_DIR_AUDIT}/auditd-conf.sh}" ]; then
	_mk_auditd_config || { error $"Unable to read file %s" "${VAR_DIR_AUDIT}/auditd-conf.sh"; exit 1; }
fi

_source_conf() {
source "${VAR_DIR_AUDIT}/auditd-conf.sh" || exit 1
}
_source_conf

# For yad checkboxes, the words TRUE or FALSE are required.
# We change the following parameters no to FALSE and yes to TRUE
_yad_declare() {
for i in local_events write_logs distribute_network; do
	# The variables have the same name as the lines in the config
	eval 'if [[ $'$i' == "yes" ]]; then declare $i=TRUE; else declare $i=FALSE; fi' || { error $"Unable to set variable %s" "$i"; exit 1; }
done
}
_yad_declare

_tag1="<span weight='bold'>"
_tag2="</span>"
_NUMBER="$(( ${RANDOM:0:4} * 13 ))"

_yad() {
yad --plug=$_NUMBER --tabnum=1 --form \
	--text-align=center \
	--bool-fmt=T \
	--text=$"<span size='xx-large' weight='bold'>Audit daemon settings</span>" \
	--image=security-medium \
	--scroll \
	--field=$"Local events::LBL" "!" \
	  --field=$"(Status) Local events:CHK" "${local_events:-FALSE}" \
	--field=$"Log file::LBL" "!" \
	  --field=$"${_tag1}(String) Log file${_tag2}" "${log_file:--}" \
	--field=$"Write logs::LBL" "!" \
	  --field=$"(Status) Write logs:CHK" "${write_logs:-FALSE}" \
	--field=$"Log format::LBL" "!" \
	  --field=$"${_tag1}(Value) Log format${_tag2}:CB" "$(if [ -n "$log_format" ]; then echo "RAW!ENRICHED!" | sed "s/$log_format\!/\^$log_format\!/g;s/\!\$//"; else echo "RAW!ENRICHED"; fi)" \
	--field=$"Log group::LBL" "!" \
	  --field=$"${_tag1}(String) Log group${_tag2}" "${log_group}" \
	--field=$"Priority boost::LBL" "!" \
	  --field=$"${_tag1}(Value) Priority boost${_tag2}:NUM" "${priority_boost:-0}!" \
	--field=$"Flush::LBL" "!" \
	--field=$"(Value) Flush:CHK" "$(if [ -n "$flush" ]; then echo "none!incremental!incremental_async!data!sync!" | sed "s/$flush\!/\^$flush\!/g;s/\!\$//"; else echo "none!incremental!incremental_async!data!sync"; fi)" \
	--field=$"Freq::LBL" "!" \
	  --field=$"${_tag1}(Value) Freq${_tag2}:NUM" "${freq:-0}!" \
	--field=$"Max log fileaction::LBL" "!" \
	  --field=$"${_tag1}(Value) Max log fileaction${_tag2}:CB" "$(if [ -n "$max_log_fileaction" ]; then echo "ignore!syslog!suspend!rotate!keep_logs!" | sed "s/$max_log_fileaction\!/\^$max_log_fileaction\!/g;s/\!\$//"; else echo "ignore!syslog!suspend!rotate!keep_logs"; fi)" \
	--field=$"Num logs::LBL" "!" \
	  --field=$"${_tag1}(Value) Num logs${_tag2}:NUM" "${num_logs:-0}!" \
	--field=$"Disp Qos::LBL" "!" \
	  --field=$"${_tag1}(Value) Disp Qos${_tag2}:CB" "$(if [ -n "$disp_qos" ]; then echo "lossy!lossless!" | sed "s/$disp_qos\!/\^$disp_qos\!/g;s/\!\$//"; else echo "lossy!lossless"; fi)" \
	--field=$"Dispatcher::LBL" "!" \
	  --field=$"${_tag1}(String) dispatcher${_tag2}" "${dispatcher}" \
	--field=$"Distribute network::LBL" "!" \
	  --field=$"(Status) Distribute network:CHK" "${distribute_network:-FALSE}" \
	--field=$"Name format::LBL" "!" \
	  --field=$"${_tag1}(Value) Name format${_tag2}:CB" "$(if [ -n "$name_format" ]; then echo "none!hostname!fqd!numeric!user!" | sed "s/$name_format\!/\^$name_format\!/g;s/\!\$//"; else echo "none!hostname!fqd!numeric!user"; fi)" \
	--field=$"Name::LBL" "!" \
	  --field=$"${_tag1}(String) Name${_tag2}" "${name:--}" \
	--field=$"Max log file::LBL" "!" \
	  --field=$"${_tag1}(Value) Max log file${_tag2}:NUM" "${max_log_file:-0}!" \
	--field=$"Action Mail Acct::LBL" "!" \
	  --field=$"${_tag1}(String) Action Mail Acct${_tag2}:" "${action_mail_acct:--}" \
	--field=$"Space left::LBL" "!" \
	  --field=$"${_tag1}(Value) Space left${_tag2}:NUM" "${space_left:-0}!" \
	--field=$"Space left action::LBL" "!" \
	--field=$"${_tag1}(String) Space left action${_tag2}:CBE" "$(if [ -n "$space_left_action" ]; then echo "ignore!syslog!rotate!email!suspend!single!halt!exec!" | sed "s/$space_left_action\!/\^$space_left_action\!/g;s/\!\$//"; else echo "ignore!syslog!rotate!email!suspend!single!halt!exec"; fi)" \
	--field=$"Disk full action::LBL" "!" \
	  --field=$"${_tag1}(String) Disk full action${_tag2}:CBE" "$(if [ -n "$disk_full_action" ]; then echo "ignore!syslog!rotate!email!suspend!single!halt!exec!" | sed "s/$disk_full_action\!/\^$disk_full_action\!/g;s/\!\$//"; else echo "ignore!syslog!rotate!email!suspend!single!halt!exec"; fi)" \
	--field=$"Disk error action::LBL" "!" \
	  --field=$"${_tag1}(String) Disk error action${_tag2}:CBE" "$(if [ -n "$disk_error_action" ]; then echo "ignore!syslog!rotate!email!suspend!single!halt!exec!" | sed "s/$disk_error_action\!/\^$disk_error_action\!/g;s/\!\$//"; else echo "ignore!syslog!rotate!email!suspend!single!halt!exec"; fi)" &

yad --plug=$_NUMBER --tabnum=2 --form \
	--text-align=center \
	--bool-fmt=T \
	--text=$"<span size='xx-large' weight='bold'>Network server</span>" \
	--image=security-medium \
	--scroll \
	--field=$"Tcp listen port::LBL" "!" \
	  --field=$"${_tag1}(Value) Tcp listen port${_tag2}::NUM" "${tcp_listen_port:-1}!1..65535!1" \
	--field=$"Tcp max per addr::LBL" "!" \
	  --field=$"${_tag1}(Value) Tcp max per addr${_tag2}::NUM" "${tcp_max_per_addr_port:-1}!1..65535!1" \
	--field=$"Systemd firewalling params:LBL" "!" \
	  --field=$"${_tag1}(Value) Allowed IPs${_tag2}::TXT" "$(echo -e "${systemd_allowed_ip_list// /\\n}")" \
	  --field=$"${_tag1}(Value) Denied IPs${_tag2}::TXT" "$(echo -e "${systemd_denied_ip_list// /\\n}")" &

#systemd-firewalling-params
var="$(yad --key=$_NUMBER --notebook --stack --expand --tab=$"Audit" --tab=$"Network" \
	--width=800 \
	--height=800 \
	--title=$"linux-infosec-setupper" \
	--button=$"Load defaults!view-refresh:3" --button=$"yad-save:0" --button=$"yad-close:1")"
}
	_status="$?"
# If we clicked on the "Load default" button, we decided to restore the settings.
# The exit code after clicking on this button is 3. We restore the config if we clicked on this button
if [ "$_status" == 3 ]; then
	_mk_auditd_config || { error $"Unable to read file %s" "${VAR_DIR_AUDIT}/auditd-conf.sh"; exit 1; }
	_source_conf
	_yad_declare
	_yad

fi	

# If we decide to undo the changes and not change anything, the var variable will be empty.
[ -z "$var" ] && exit 0

# The default delimiter in yad is |
var2="$(while read -rd '|' line; do
	echo $line
done <<<"$var" | sed '/^$/d' | \
	sed 's/TRUE/1/
	    ;s/FALSE/0/
	    ;1s/^/--difok /
	    ;2s/^/--minlen /
	    ;3s/^/--dcredit /
	    ;4s/^/--ucredit /
	    ;5s/^/--lcredit /
	    ;6s/^/--ocredit /
	    ;7s/^/--minclass /
	    ;8s/^/--maxrepeat /
	    ;9s/^/--maxsequence /
	    ;10s/^/--maxclassrepeat /
	    ;11s/^/--usersubstr /
	    ;12s/^/--retry /
	    ;13s/^/--gecoscheck /
	    ;14s/^/--dictcheck /
	    ;15s/^/--usercheck /
	    ;16s/^/--enforcing /
	    ;17s/^/--enforce_for_root /
	    ;18s/^/--local_users_only /' | tr '\n' ' ')"

source "${SHARE_DIR_PWQUALITY}/back_pwquality.sh"
_mk_pwquality_conf $var2 > "${DESTDIR}/etc/security/pwquality.conf" || { error $"Unable to write to file %s" "${DESTDIR}/etc/security/pwquality.conf"; exit 1; }

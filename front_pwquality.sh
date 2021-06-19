#!/bin/bash

source "${DESTDIR}/usr/share/linux-infosec-setupper/common.sh"

if ! [[ -f "${VAR_DIR_PWQUALITY}/pw_changed" ]]; then
	cat "${SHARE_DIR_PWQUALITY}/pw_default" > "${DESTDIR}/etc/security/pwquality.conf"
	install -D -m 000 /dev/null "${VAR_DIR_PWQUALITY}/pw_changed"
fi	

source "${SHARE_DIR_PWQUALITY}/parse_pwquality.sh"
while read -r line; do declare "$line"; done < <(_pw_parse_conf) || { error $"Unable to parse /etc/security/pwquality.conf correctly"; exit 1; }

for i in gecoscheck enforce_for_root local_users_only dictcheck usercheck enforcing; do
	eval 'if [[ $'$i' == 1 ]]; then declare $i=TRUE; else declare $i=FALSE; fi'
done
var="$(yad --title=$"linux-infosec-setupper" --form --text=$"Password policies setup" --image=/usr/share/icons/hicolor/48x48/apps/gcr-key.png --scroll --width=800 --height=800 --button=$"Load defaults!view-refresh:3" --button=$"yad-save:0" --button=$"yad-close:1" \
	--field=$"Number of characters in the new password that must not be present in the old password::LBL" "!" \
	  --field=$"Value (difok)::NUM" "$difok!1..9999!1" \
	--field=$"Minimum acceptable size for the new password:LBL" "!" \
	  --field=$"Value (minlen):NUM" "$minlen!6..9999!1" \
	--field=$"The maximum credit for having digits in the new password::LBL" "!" \
	  --field=$"Value (dcredit):NUM" "$dcredit!-9999..+9999!1" \
	--field=$"The maximum credit for having uppercase characters in the new password:LBL" "!" \
	  --field=$"Value (ucredit):NUM" "$ucredir!-9999..+9999!1" \
	--field=$"The maximum credit for having lowercase characters in the new password:LBL" "!" \
	  --field=$"Value (lcredit):NUM" "$lcredir!-9999..+9999!1" \
	--field=$"The maximum credit for having other characters in the new password:LBL" "!" \
	  --field=$"Value (ocredit):NUM" "$ocredir!-9999..+9999!1" \
	--field=$"The minimum number of required classes of characters for the new password:LBL" "!" \
	  --field=$"Value (minclass):NUM" "$minclass!0..9999!1" \
	--field=$"The maximum number of allowed same consecutive charatcers in the new password:LBL" "!" \
	  --field=$"Value (maxrepeat):NUM" "$maxrepeat!0..9999!1" \
	--field=$"The maximum length of monotonic chatacter sequences in the new password:LBL" "!" \
	  --field=$"Value (maxsequence):NUM" "$maxsequence!0..9999!1" \
	--field=$"The maximum number of allowed consecutive characters of the same class in the new password:LBL" "!" \
	  --field=$"Value (maxclassrepeat):NUM" "$maxclassrepeat!0..9999!1" \
	--field=$"Check whether the password contains a substring of at least N length:LBL" "!" \
	  --field=$"Value (usersubstr):NUM" "$usersubstr:0..9999:1" \
	--field=$"Prompt the user at most N times before returning error:LBL" "!" \
	  --field=$"Value (retry):NUM" "$retry:0..9999:1" \
	--field=$"Check whether the words longer than 3 characters from the GECO field of passwd:LBL" "!" \
	  --field=$"Status (gecoscheck):CHK" "$gecoscheck" \
	--field=$"Check whether the password macthices a word in a dictionary:LBL" "!" \
	  --field=$"Status (dictcheck):CHK" "$dictcheck" \
	--field=$"Check whether the password contains the user name in some form:LBL" "!" \
	  --field=$"Status (usercheck):CHK" "$usercheck" \
	--field=$"Reject the password if it fails the checks:LBL" "!" \
	  --field=$"Status (enforcing):CHK" "$enforcing" \
	--field=$"Return error on failed check even if the user changing the password is root:LBL" "!" \
	  --field=$"Status (enforce_for_root):CHK" "$enforce_for_root" \
	--field=$"Not test the password quality for users that are not present in /etc/passwd:LBL" "!" \
	--field=$"Status (local_users_only):CHK" "$local_users_only")"
	_status="$?"
if [ "$_status" == 3 ]; then
	cat "${SHARE_DIR_PWQUALITY}/pw_default" > "${DESTDIR}/etc/security/pwquality.conf"
fi	

[ -z "$var" ] && exit 0

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
_mk_pwquality_conf $var2 > "${DESTDIR}/etc/security/pwquality.conf"

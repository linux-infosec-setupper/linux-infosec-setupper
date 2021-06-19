_is_auditd_enabled(){
	# may add additional checks later
	systemctl is-active -q autitd
}

_mk_audit


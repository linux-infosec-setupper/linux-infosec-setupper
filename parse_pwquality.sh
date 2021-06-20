_pw_parse_conf() {
while read -r line; do
	case "$line" in
		*=*) echo "${line// /}" ;;
		*)   echo "${line}=1"   ;;
	esac
done < "${DESTDIR}/etc/security/pwquality.conf"
}

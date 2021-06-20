all:
	cd po/back_auditd ; msgfmt -o linux-infosec-setupper-back_auditd.mo ru.po

install:
	# bin is for scripts which will run sbin/* via pkexec
	#mkdir -p $(DESTDIR)/usr/bin
	# sbin is for executables
	mkdir -p $(DESTDIR)/usr/sbin
	install -m0755 front_auditd_cli.sh $(DESTDIR)/usr/sbin/linux-infosec-setupper-auditd-cli
	mkdir -p $(DESTDIR)/usr/share/linux-infosec-setupper
	mkdir -p $(DESTDIR)/usr/share/linux-infosec-setupper/audit
	#mkdir -p $(DESTDIR)/usr/share/linux-infosec-setupper/pwquality
	install -m0644 common.sh $(DESTDIR)/usr/share/linux-infosec-setupper/common.sh
	install -m0644 back_auditd.sh $(DESTDIR)/usr/share/linux-infosec-setupper/audit/back_auditd.sh
	mkdir -p $(DESTDIR)/var/lib/linux-infosec-setupper
	mkdir -p $(DESTDIR)/var/lib/linux-infosec-setupper/audit
	#mkdir -p $(DESTDIR)/var/lib/linux-infosec-setupper/pwquality
	chmod -R 0700 $(DESTDIR)/var/lib/linux-infosec-setupper
	
	mkdir -p $(DESTDIR)/usr/share/locale/ru/LC_MESSAGES
	install -m0644 po/back_auditd/linux-infosec-setupper-back_auditd.mo $(DESTDIR)/usr/share/locale/ru/LC_MESSAGES

rpm:
	# https://stackoverflow.com/a/1909390
	$(eval TMP := $(shell mktemp --suffix=.tar.gz))
	tar -zcf $(TMP) .
	RPM_NAME=$(shell rpmspec -q --srpm --qf '%{name}' linux-infosec-setupper.spec)
	RPM_VERSION=$(shell rpmspec -q --srpm --qf '%{version}' linux-infosec-setupper.spec)
	mv $(TMP) $(shell rpmspec -q --srpm --qf '%{name}-%{version}.tar.gz' linux-infosec-setupper.spec)
	rpmbuild -bb --define "_sourcedir $(shell pwd)" linux-infosec-setupper.spec

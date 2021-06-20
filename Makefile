all:
	@echo Run make install

install:
	# bin is for scripts which will run sbin/* via pkexec
	mkdir -p $(DESTDIR)/usr/bin
	# sbin is for executables
	mkdir -p $(DESTDIR)/usr/sbin
	install -m0755 front_auditd_cli.sh $(DESTDIR)/usr/sbin/linux-infosec-setupper-auditd-cli
	install -m0755 front_pwquality_cli.sh $(DESTDIR)/usr/sbin/linux-infosec-setupper-pwquality-cli
	install -m0755 front_pwquality.sh $(DESTDIR)/usr/sbin/linux-infosec-setupper-pwquality-gui
	install -m0755 front_auditd.sh $(DESTDIR)/usr/sbin/linux-infosec-setupper-auditd-gui
	mkdir -p $(DESTDIR)/usr/share/linux-infosec-setupper
	mkdir -p $(DESTDIR)/usr/share/linux-infosec-setupper/audit
	mkdir -p $(DESTDIR)/usr/share/linux-infosec-setupper/pwquality
	install -m0644 pw_default $(DESTDIR)/usr/share/linux-infosec-setupper/pwquality/pw_default
	install -m0644 common.sh $(DESTDIR)/usr/share/linux-infosec-setupper/common.sh
	install -m0644 back_auditd.sh $(DESTDIR)/usr/share/linux-infosec-setupper/audit/back_auditd.sh
	install -m0644 back_pwquality.sh $(DESTDIR)/usr/share/linux-infosec-setupper/pwquality/back_pwquality.sh
	mkdir -p $(DESTDIR)/var/lib/linux-infosec-setupper
	mkdir -p $(DESTDIR)/var/lib/linux-infosec-setupper/audit
	mkdir -p $(DESTDIR)/var/lib/linux-infosec-setupper/pwquality
	chmod -R 0700 $(DESTDIR)/var/lib/linux-infosec-setupper
	
	mkdir -p $(DESTDIR)/usr/share/locale/ru/LC_MESSAGES
	msgfmt -o $(DESTDIR)/usr/share/locale/ru/LC_MESSAGES/linux-infosec-setupper.mo po/ru.po

	mkdir -p $(DESTDIR)/usr/share/polkit-1/actions
	install -m0644 polkit/org.nixtux.pkexec.linux-infosec-setupper-pwquality-gui.policy $(DESTDIR)/usr/share/polkit-1/actions/
	install -m0644 polkit/org.nixtux.pkexec.linux-infosec-setupper-auditd-gui.policy $(DESTDIR)/usr/share/polkit-1/actions/
	install -m0755 polkit/linux-infosec-setupper-pwquality-gui.sh $(DESTDIR)/usr/bin/linux-infosec-setupper-pwquality-gui
	install -m0755 polkit/linux-infosec-setupper-auditd-gui.sh $(DESTDIR)/usr/bin/linux-infosec-setupper-auditd-gui

rpm:
	# https://stackoverflow.com/a/1909390
	$(eval TMP := $(shell mktemp --suffix=.tar.gz))
	tar -zcf $(TMP) .
	RPM_NAME=$(shell rpmspec -q --srpm --qf '%{name}' linux-infosec-setupper.spec)
	RPM_VERSION=$(shell rpmspec -q --srpm --qf '%{version}' linux-infosec-setupper.spec)
	mv $(TMP) $(shell rpmspec -q --srpm --qf '%{name}-%{version}.tar.gz' linux-infosec-setupper.spec)
	rpmbuild -bb --define "_sourcedir $(shell pwd)" linux-infosec-setupper.spec

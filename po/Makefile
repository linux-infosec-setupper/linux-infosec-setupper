update-pot:
	( cat linux-infosec-setupper.pot ; for i in ../*.sh ; do bash --dump-po-strings $i ; done ) | msguniq > linux-infosec-setupper.pot.2
	mv -v linux-infosec-setupper.pot.2 linux-infosec-setupper.pot

update-po:
	msgmerge -o ru.po ru.po linux-infosec-setupper.pot

###############################################################################
# Copyright © 2016 Stéphane Veyret stephane_DOT_veyret_AT_neptura_DOT_org
#
# This file is part of MagiCd.
#
# MagiCd is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# MagiCd is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# MagiCd. If not, see <http://www.gnu.org/licenses/>.
###############################################################################

SRC= $(wildcard po/*.po)
MO= $(SRC:.po=.mo)

all: $(MO)

%.mo: %.po
	msgfmt -o $@ $<

.PHONY: clean mrproper install

install:
	install -d -m755 "${DESTDIR}/usr/share/MagiCd/magicd.d"
	install -d -m755 "${DESTDIR}/etc/magicd.d"
	install -d -m755 "${DESTDIR}/etc/bash/bashrc.d"
	install -m644 shell/magicd "${DESTDIR}/usr/share/MagiCd"
	install -m644 shell/magicd.d/* "${DESTDIR}/usr/share/MagiCd/magicd.d"
	install -m644 magicd.sh "${DESTDIR}/etc/bash/bashrc.d"
	for lang in po/*.mo; do \
		if [[ -f $${lang} ]]; then \
			install -D -m644 $${lang} "${DESTDIR}/usr/share/locale/$$(basename $${lang} .mo)/LC_MESSAGES/magicd.mo"; \
		fi \
	done

clean:
	rm -f po/*.mo

mrproper: clean


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
# Script to be placed in bashrc.d in order to start MagiCd at bash startup.

# Check for interactive bash and that we haven't already been sourced.
if [[ -n "${BASH_VERSION}" ]] && [[ -n "${PS1}" ]] && [[ -z "${MAGICD_HOME}" ]]; then
	# Check if MagiCd is in expected directory
	if [[ -r /usr/share/MagiCd/magicd ]]; then
		source /usr/share/MagiCd/magicd
		alias cd="magicd_cd_"
		alias clean="magicd_clean_"
	fi
fi


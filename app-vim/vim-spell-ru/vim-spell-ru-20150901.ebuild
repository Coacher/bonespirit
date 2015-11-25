# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

VIM_SPELL_LANGUAGE="Russian"

inherit vim-spell

SPELL_FTP_URI="ftp://ftp.vim.org/pub/vim/unstable/runtime/spell"
SPELL_ENCODINGS="cp1251 koi8-r utf-8"

SRC_URI="${SPELL_FTP_URI}/README_${VIM_SPELL_CODE}.txt"
for ENCODING in ${SPELL_ENCODINGS}; do
	SRC_URI+="
		${SPELL_FTP_URI}/${VIM_SPELL_CODE}.${ENCODING}.spl
		${SPELL_FTP_URI}/${VIM_SPELL_CODE}.${ENCODING}.sug
	"
done

LICENSE="myspell-ru_RU-ALexanderLebedev"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack() {
	mkdir -p "${WORKDIR}/${P}" || die
	cd "${DISTDIR}" || die
	cp -LR ${A} "${WORKDIR}/${P}" || die
}

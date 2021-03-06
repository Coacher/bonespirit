# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

VIM_SPELL_LANGUAGE=Russian

inherit vim-spell

SPELL_FTP_URI="ftp://ftp.vim.org/pub/vim/unstable/runtime/spell"
SPELL_ENCODINGS="cp1251 koi8-r utf-8"

SRC_URI="${SPELL_FTP_URI}/README_${VIM_SPELL_LOCALE}.txt"
for SPELL_ENCODING in ${SPELL_ENCODINGS}; do
	SRC_URI+="
		${SPELL_FTP_URI}/${VIM_SPELL_LOCALE}.${SPELL_ENCODING}.spl
		${SPELL_FTP_URI}/${VIM_SPELL_LOCALE}.${SPELL_ENCODING}.sug
	"
done

LICENSE="myspell-ru_RU-AlexanderLebedev"
KEYWORDS="~amd64 ~x86"

RESTRICT=mirror

src_unpack() {
	mkdir "${WORKDIR}/${P}" || die
	cd "${DISTDIR}" || die
	cp -aLR ${A} "${WORKDIR}/${P}" || die
}

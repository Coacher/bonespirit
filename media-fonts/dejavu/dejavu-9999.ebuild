# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font versionator git-r3

DESCRIPTION="DejaVu fonts, Bitstream Vera with a wider range of characters"
HOMEPAGE="http://dejavu.sourceforge.net/"
EGIT_REPO_URI="git://github.com/dejavu-fonts/dejavu-fonts.git"

LICENSE="BitstreamVera"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="
	app-i18n/unicode-data
	dev-perl/Font-TTF
	media-gfx/fontforge
	media-libs/fontconfig
	x11-apps/mkfontdir
	x11-apps/mkfontscale
"

FONT_SUFFIX="ttf"
FONT_S="${S}/build"
FONT_CONF=(
	"${S}"/fontconfig/20-unhint-small-dejavu-sans-mono.conf
	"${S}"/fontconfig/20-unhint-small-dejavu-sans.conf
	"${S}"/fontconfig/20-unhint-small-dejavu-serif.conf
	"${S}"/fontconfig/57-dejavu-sans-mono.conf
	"${S}"/fontconfig/57-dejavu-sans.conf
	"${S}"/fontconfig/57-dejavu-serif.conf
)

src_compile() {
	emake \
		BLOCKS=/usr/share/unicode-data/Blocks.txt \
		UNICODEDATA=/usr/share/unicode-data/UnicodeData.txt \
		FC-LANG=/usr/share/fc-lang \
		full sans \
		|| die "emake failed"
}

src_install() {
	font_src_install

	dodoc build/*.txt
}

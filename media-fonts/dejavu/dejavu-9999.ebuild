# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font git-r3

DESCRIPTION="DejaVu fonts, Bitstream Vera with a wider range of characters"
HOMEPAGE="https://dejavu-fonts.github.io/"
EGIT_REPO_URI="https://github.com/dejavu-fonts/dejavu-fonts.git"

LICENSE="BitstreamVera"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	app-i18n/unicode-data
	dev-perl/Font-TTF
	dev-perl/IO-String
	media-gfx/fontforge
	media-libs/fontconfig
"

RESTRICT="binchecks strip"

DOCS="README.md"

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
		BLOCKS="${EPREFIX}/usr/share/unicode-data/Blocks.txt" \
		UNICODEDATA="${EPREFIX}/usr/share/unicode-data/UnicodeData.txt" \
		FC-LANG="${EPREFIX}/usr/share/fc-lang" \
		full sans
}

src_install() {
	font_src_install
	dodoc build/*.txt
}

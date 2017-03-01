# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font git-r3

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlei18n/noto-fonts"
EGIT_REPO_URI=( {https,git}://github.com/googlei18n/${PN}-fonts.git )

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

DOCS="FAQ.md README.md"

FONT_SUFFIX="ttf"
FONT_S="${S}/hinted"
FONT_CONF=( "${FILESDIR}/59-${PN}.conf" )

src_prepare() {
	default_src_prepare
	rm -r "${FONT_S}"/Arimo* "${FONT_S}"/Cousine* "${FONT_S}"/Tinos* || die
}

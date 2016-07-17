# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font

DESCRIPTION="Open licensed fonts metrically compatible with Microsoft core fonts"
HOMEPAGE="
	https://www.google.com/fonts/specimen/Arimo
	https://www.google.com/fonts/specimen/Cousine
	https://www.google.com/fonts/specimen/Tinos
	https://code.google.com/p/chromium/issues/detail?id=168879
	https://code.google.com/p/chromium/issues/detail?id=280557
"
SRC_URI="
	https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.bz2
	https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/crosextrafonts-20130214.tar.gz
	https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/crosextrafonts-carlito-20130920.tar.gz
"

LICENSE="Apache-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="ttf"
FONT_CONF=(
	"${FILESDIR}/62-croscore-arimo.conf"
	"${FILESDIR}/62-croscore-cousine.conf"
	"${FILESDIR}/62-croscore-tinos.conf"
	"${FILESDIR}/62-croscore-caladea.conf"
	"${FILESDIR}/62-croscore-carlito.conf"
)

src_install() {
	font_src_install
	FONT_S="${WORKDIR}/crosextrafonts-20130214" font_src_install
	FONT_S="${WORKDIR}/crosextrafonts-carlito-20130920" font_src_install
}

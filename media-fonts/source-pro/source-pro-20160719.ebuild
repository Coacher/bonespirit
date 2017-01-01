# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font

CODE_PV="2.030R-ro/1.050R-it" # 2016-07-19
SANS_PV="2.020R-ro/1.075R-it" # 2015-09-16
SERIF_PV="1.017R"             # 2014-12-11

DESCRIPTION="Adobe's open source font family designed for UI environments"
HOMEPAGE="
	https://adobe-fonts.github.io/source-code-pro/
	https://adobe-fonts.github.io/source-sans-pro/
	https://adobe-fonts.github.io/source-serif-pro/
"
SRC_URI="
	https://github.com/adobe-fonts/source-code-pro/archive/${CODE_PV}.tar.gz -> source-code-pro-${PV}.tar.gz
	https://github.com/adobe-fonts/source-sans-pro/archive/${SANS_PV}.tar.gz -> source-sans-pro-${PV}.tar.gz
	https://github.com/adobe-fonts/source-serif-pro/archive/${SERIF_PV}.tar.gz -> source-serif-pro-${PV}.tar.gz
"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="otf"
FONT_CONF=( "${FILESDIR}/60-${PN}.conf" )

src_unpack() {
	default_src_unpack
	mkdir "${WORKDIR}/${P}" || die
	cp -aLR source-*/OTF/*.otf "${WORKDIR}/${P}" || die
}

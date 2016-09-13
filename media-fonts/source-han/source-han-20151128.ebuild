# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font

SANS_PV="1.004R" # 2015-06-16
CODE_PV="2.000R" # 2015-11-28

DESCRIPTION="Adobe's CJK open source font family designed for UI environments"
HOMEPAGE="
	https://github.com/adobe-fonts/source-han-sans
	https://github.com/adobe-fonts/source-han-code-jp
"
SRC_URI="
	https://github.com/adobe-fonts/source-han-sans/archive/${SANS_PV}.tar.gz -> source-han-sans-${PV}.tar.gz
	https://github.com/adobe-fonts/source-han-code-jp/archive/${CODE_PV}.tar.gz -> source-han-code-jp-${PV}.tar.gz
"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="otf"
FONT_CONF=( "${FILESDIR}/61-${PN}.conf" )

src_unpack() {
	default_src_unpack
	mkdir "${WORKDIR}/${P}" || die
	cp -aLR \
		source-han-sans-${SANS_PV}/SubsetOTF/**/*.otf \
		source-han-code-jp-${CODE_PV}/OTF/*.otf \
		"${WORKDIR}/${P}" || die
}

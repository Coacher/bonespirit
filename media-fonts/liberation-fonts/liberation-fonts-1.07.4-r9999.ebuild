# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font

DESCRIPTION="A font family metrically compatible with Arial/Times/Courier, by Red Hat"
HOMEPAGE="https://pagure.io/liberation-fonts"
SRC_URI="
	!fontforge? ( https://releases.pagure.org/liberation-fonts/${PN}-ttf-${PV}.tar.gz )
	fontforge? ( https://releases.pagure.org/liberation-fonts/${P}.tar.gz )
"

LICENSE="GPL-2-with-exceptions"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="fontforge"

DEPEND="fontforge? ( media-gfx/fontforge )"

FONT_SUFFIX="ttf"
FONT_CONF=( "${FILESDIR}/60-liberation.conf" )

pkg_setup() {
	if use fontforge; then
		FONT_S="${S}/${PN}-ttf-${PV}"
	else
		FONT_S="${WORKDIR}/${PN}-ttf-${PV}"
		S="${FONT_S}"
	fi
	font_pkg_setup
}

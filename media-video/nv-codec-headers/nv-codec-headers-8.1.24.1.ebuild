# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit vcs-snapshot

DESCRIPTION="FFmpeg version of Nvidia Codec SDK headers"
HOMEPAGE="https://github.com/FFmpeg/nv-codec-headers"
SRC_URI="https://github.com/FFmpeg/nv-codec-headers/archive/n${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

src_compile() { :; }

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" LIBDIR="$(get_libdir)" install
	einstalldocs
}

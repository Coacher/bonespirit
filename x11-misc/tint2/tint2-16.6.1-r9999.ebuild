# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils xdg-utils

DESCRIPTION="A lightweight panel/taskbar"
HOMEPAGE="https://gitlab.com/o9000/tint2"
SRC_URI="https://gitlab.com/o9000/tint2/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="startup-notification svg tint2conf"

RDEPEND="
	>=media-libs/imlib2-1.4.2[X,png]
	>=x11-libs/libXrandr-1.3
	dev-libs/glib:2
	x11-libs/cairo[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libXrender
	x11-libs/pango
	startup-notification? ( x11-libs/startup-notification )
	svg? ( gnome-base/librsvg:2 )
	tint2conf? ( x11-libs/gtk+:2 )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		-DENABLE_TINT2CONF=$(usex tint2conf)
		-DENABLE_RSVG=$(usex svg)
		-DENABLE_SN=$(usex startup-notification)
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	gnome2_icon_cache_update
	if use tint2conf; then
		xdg_mimeinfo_database_update
		xdg_desktop_database_update
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	if use tint2conf; then
		xdg_mimeinfo_database_update
		xdg_desktop_database_update
	fi
}

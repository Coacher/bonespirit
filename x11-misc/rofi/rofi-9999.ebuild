# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools toolchain-funcs git-r3

DESCRIPTION="A window switcher, run dialog and dmenu replacement"
HOMEPAGE="https://davedavenport.github.io/rofi/"
EGIT_REPO_URI="git://github.com/DaveDavenport/${PN}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="i3 windowmode"

REQUIRED_USE="i3? ( windowmode )"

RDEPEND="
	dev-libs/glib:2
	x11-libs/cairo[X,xcb]
	x11-libs/libX11
	x11-libs/libxcb[xkb]
	x11-libs/libxkbcommon[X]
	x11-libs/pango[X]
	x11-libs/startup-notification
	x11-libs/xcb-util
	x11-libs/xcb-util-wm
	i3? ( x11-wm/i3 )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	default_src_prepare
	sed -i -e 's/-Werror //g' configure.ac || die
	eautoreconf
}

src_configure() {
	tc-export CC
	econf \
		$(use_enable windowmode) \
		$(use_enable i3 i3support)
}

src_test() {
	emake test
}

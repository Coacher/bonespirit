# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools toolchain-funcs

DESCRIPTION="A window switcher, run dialog and dmenu replacement"
HOMEPAGE="https://github.com/DaveDavenport/rofi"
SRC_URI="https://github.com/DaveDavenport/rofi/releases/download/${PV}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="drun test +windowmode"

RDEPEND="
	dev-libs/glib:2
	gnome-base/librsvg:2
	x11-libs/cairo[xcb]
	x11-libs/libxcb[xkb]
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	x11-libs/startup-notification
	x11-libs/xcb-util
	x11-libs/xcb-util-wm
	x11-libs/xcb-util-xrm
"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	test? ( dev-libs/check )
"

src_prepare() {
	default_src_prepare

	sed -i -e 's| -Werror||g' configure.ac || die
	sed -i \
		-e "s|/tmp/rofi-test.pid|${T}/rofi-test.pid|g" \
		test/helper-pidfile.c || die

	eautoreconf
}

src_configure() {
	tc-export CC
	local myeconfargs=(
		$(use_enable drun)
		$(use_enable windowmode)
		$(use_enable test check)
	)
	econf "${myeconfargs[@]}"
}

src_test() {
	emake test
}

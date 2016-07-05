# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit toolchain-funcs git-r3

DESCRIPTION="Lightweight and customizable notification daemon"
HOMEPAGE="http://www.knopwob.org/dunst/"
EGIT_REPO_URI="git://github.com/knopwob/${PN}.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dunstify"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libxdg-basedir
	sys-apps/dbus
	x11-libs/cairo[X,glib]
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/pango[X]
	dunstify? ( x11-libs/libnotify )
"

DEPEND="${RDEPEND}
	dev-lang/perl:*
	virtual/pkgconfig
"

src_prepare() {
	default_src_prepare

	# Remove flags that cause problems.
	sed -i -e 's| -Os\>||' -e 's| -g\>||' config.mk || die

	# Respect CFLAGS when building dunstify.
	sed -i -e '/dunstify\.c/s|-o|${CFLAGS} -o|' Makefile || die

	# Remove forgotten Xft include.
	sed -i -e '/Xft\.h/d' x.h || die
}

src_compile() {
	tc-export CC
	default_src_compile

	use dunstify && emake dunstify
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
	einstalldocs

	use dunstify && dobin dunstify
}

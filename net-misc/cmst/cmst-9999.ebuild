# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils git-r3

DESCRIPTION="Qt GUI for Connman with system tray icon"
HOMEPAGE="https://github.com/andrew-bibb/cmst"
EGIT_REPO_URI="https://github.com/andrew-bibb/cmst.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
"
RDEPEND="${DEPEND}
	net-misc/connman
"

src_prepare() {
	default_src_prepare

	# Do not install ugly default icon.
	rm images/application/cmst-icon.png || die

	# Disable tear off menu in systray.
	sed -i \
		-e '/setTearOff/s/true/false/g' \
		apps/cmstapp/code/control_box/controlbox.cpp || die
}

src_configure() {
	export USE_LIBPATH="${EPREFIX}/usr/$(get_libdir)/${PN}"
	eqmake5 DISTRO=gentoo
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	rm -r "${ED}"usr/share/licenses || die
}

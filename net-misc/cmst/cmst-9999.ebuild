# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit qmake-utils git-r3

DESCRIPTION="Qt GUI for Connman with system tray icon"
HOMEPAGE="https://github.com/andrew-bibb/cmst"
EGIT_REPO_URI=( {https,git}://github.com/andrew-bibb/${PN}.git )

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

	# Use Gentoo groups for permissions. See Gentoo bug 596744.
	sed -i \
		-e '/group=/s/network/plugdev/' \
		apps/rootapp/system/distro/arch/org.cmst.roothelper.conf || die
}

src_configure() {
	export USE_LIBPATH="${EPREFIX}/usr/$(get_libdir)/${PN}"
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	rm -r "${ED}"usr/share/licenses || die
}
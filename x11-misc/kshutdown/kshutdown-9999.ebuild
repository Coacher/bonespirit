# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils gnome2-utils qmake-utils subversion

DESCRIPTION="A graphical shutdown utility"
HOMEPAGE="https://kshutdown.sourceforge.io/"
ESVN_REPO_URI="https://svn.code.sf.net/p/kshutdown/code/trunk/kshutdown2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt5"

RDEPEND="
	!kde-misc/kshutdown
	!qt5? (
		dev-qt/qtcore:4
		dev-qt/qtdbus:4
		dev-qt/qtgui:4
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtdbus:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"
DEPEND="${RDEPEND}"

src_configure() {
	cd src || die && $(usex qt5 'eqmake5' 'eqmake4')
}

src_compile() {
	emake -C src DESTDIR="${D}"
}

src_install() {
	emake -C src INSTALL_ROOT="${D}" install
	einstalldocs

	newicon -s scalable "${S}/src/images/hisc-app-${PN}.svg" ${PN}.svg
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

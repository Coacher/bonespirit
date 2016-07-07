# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

KDE_MINIMAL=4.8
KDE_REQUIRED=optional

inherit eutils fdo-mime gnome2-utils kde4-base qmake-utils subversion

DESCRIPTION="A graphical shutdown utility"
HOMEPAGE="http://kshutdown.sourceforge.net/"
ESVN_REPO_URI="svn://svn.code.sf.net/p/${PN}/code/trunk/${PN}2"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	!kde? (
		dev-qt/qtcore:4
		dev-qt/qtdbus:4
		dev-qt/qtgui:4
	)
"
DEPEND="${RDEPEND}"

src_prepare() {
	if use kde; then
		kde4-base_src_prepare
	else
		default_src_prepare
	fi

	# Fix icons installation in Qt4 builds.
	sed -i -e '/\.extra/s|/usr|$(INSTALL_ROOT)/usr|' src/src.pro || die
}

src_configure() {
	if use kde; then
		kde4-base_src_configure
	else
		cd src || die && eqmake4
	fi
}

src_compile() {
	if use kde; then
		kde4-base_src_compile
	else
		emake -C src DESTDIR="${D}"
	fi
}

src_install() {
	if use kde; then
		kde4-base_src_install
	else
		emake -C src INSTALL_ROOT="${D}" install
	fi

	newicon -s scalable "${S}/src/images/hisc-app-${PN}.svg" ${PN}.svg
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils desktop gnome2-utils subversion

DESCRIPTION="A graphical shutdown utility"
HOMEPAGE="https://kshutdown.sourceforge.io/"
ESVN_REPO_URI="https://svn.code.sf.net/p/kshutdown/code/trunk/kshutdown2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	!kde-misc/kshutdown
"
DEPEND="${RDEPEND}"

src_prepare() {
	cmake-utils_src_prepare
	sed -i -e '/extras/d' src/actions/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DKS_PURE_QT=Yes
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	newicon -s scalable "${S}/src/images/hisc-app-${PN}.svg" ${PN}.svg
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

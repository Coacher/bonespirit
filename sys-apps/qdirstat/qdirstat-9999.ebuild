# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils qmake-utils xdg-utils git-r3

DESCRIPTION="Qt tool to show where your disk space has gone and to help you to clean it up"
HOMEPAGE="https://github.com/shundhammer/qdirstat"
EGIT_REPO_URI=( {https,git}://github.com/shundhammer/${PN}.git )

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	sys-libs/zlib
"
REPEND="${DEPEND}
	dev-lang/perl:*
	dev-perl/URI
"

src_prepare() {
	default_src_prepare
	# Disable unconditional documentation installation to the wrong directory.
	sed -i -e 's|doc.*\b||g' qdirstat.pro || die
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

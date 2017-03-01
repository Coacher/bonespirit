# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit kde4-base

DESCRIPTION="GTK2 and GTK3 configurator for KDE"
HOMEPAGE="https://quickgit.kde.org/?p=kde-gtk-config.git"
EGIT_BRANCH="2.2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE="debug gtk2 gtk3"

COMMON_DEPEND="
	dev-libs/glib:2
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
"
RDEPEND="${COMMON_DEPEND}
	$(add_kdeapps_dep kcmshell)
	!kde-misc/kcm_gtk
"
DEPEND="${COMMON_DEPEND}
	dev-util/automoc
"

src_prepare() {
	kde4-base_src_prepare

	# Don't create trailing spaces in generated configs.
	sed -i -e 's|\s\\n|\\n|g' src/appearancegtk2.cpp || die

	use gtk2 || cmake_comment_add_subdirectory gtkproxies
	use gtk3 || cmake_comment_add_subdirectory gtk3proxies
}

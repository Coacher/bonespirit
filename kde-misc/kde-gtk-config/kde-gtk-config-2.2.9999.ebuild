# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit kde4-base git-r3

DESCRIPTION="GTK2 and GTK3 Configurator for KDE"
HOMEPAGE="https://quickgit.kde.org/?p=kde-gtk-config.git"
EGIT_REPO_URI="git://anongit.kde.org/${PN}.git"
EGIT_BRANCH="2.2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~x86-fbsd"
SLOT="4"
IUSE="gtk gtk3 debug"

CDEPEND="
	dev-libs/glib:2
	gtk? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
"
DEPEND="
	${CDEPEND}
	dev-util/automoc
"
RDEPEND="
	${CDEPEND}
	!kde-misc/kcm_gtk
	$(add_kdeapps_dep kcmshell)
"

PATCHES=(
	"${FILESDIR}/${PN}-optional-previews.patch"
	"${FILESDIR}/${PN}-remove-dangling-spaces.patch"
)

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with gtk GTK2_PREVIEW)
		$(cmake-utils_use_with gtk3 GTK3_PREVIEW)
	)

	kde4-base_src_configure
}

pkg_postinst() {
	kde4-base_pkg_postinst
	einfo
	elog "If you notice missing icons in your GTK applications, you may have to install"
	elog "the corresponding themes for GTK. A good guess would be x11-themes/oxygen-gtk"
	elog "for example."
	einfo
}

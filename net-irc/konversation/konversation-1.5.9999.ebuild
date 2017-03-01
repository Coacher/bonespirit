# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit kde4-base

DESCRIPTION="A user-friendly IRC client for KDE"
HOMEPAGE="https://konversation.kde.org https://www.kde.org/applications/internet/konversation/"
EGIT_BRANCH="1.5"

LICENSE="GPL-2+"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="+crypt debug"

DEPEND="
	$(add_kdeapps_dep kdepimlibs)
	media-libs/phonon[qt4]
	crypt? ( app-crypt/qca:2[qt4(+)] )
"
RDEPEND="${DEPEND}
	crypt? ( app-crypt/qca:2[ssl] )
"

src_prepare() {
	kde4-base_src_prepare

	# Disable unconditional docbook documentation build.
	cmake_comment_add_subdirectory doc
}

src_configure() {
	local mycmakeargs=(
		-DWITH_QCA2=$(usex crypt)
	)
	kde4-base_src_configure
}

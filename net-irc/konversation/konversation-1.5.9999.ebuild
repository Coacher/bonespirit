# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit kde4-base git-r3

DESCRIPTION="A user-friendly and fully-featured IRC client"
HOMEPAGE="https://konversation.kde.org https://www.kde.org/applications/internet/konversation/"
EGIT_REPO_URI="git://anongit.kde.org/${PN}.git"
EGIT_BRANCH="1.5"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="+crypt debug"

DEPEND="
	$(add_kdeapps_dep kdepimlibs)
	media-libs/phonon[qt4]
	crypt? ( app-crypt/qca:2[qt4(+)] )
"
RDEPEND="${DEPEND}
	crypt? ( app-crypt/qca:2[openssl] )
"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with crypt QCA2)
	)

	kde4-base_src_configure
}

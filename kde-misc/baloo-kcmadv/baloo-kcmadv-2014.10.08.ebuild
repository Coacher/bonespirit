# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

KDE_DOC_DIRS="doc"
KDE_HANDBOOK="optional"
KDE_MINIMAL=4.13.0
inherit kde4-base git-r3

EGIT_REPO_URI="https://gitlab.com/${PN}/${PN}.git"
EGIT_COMMIT="35991b911c228731726d119084936a40ebc1447d"

DESCRIPTION="Alternative configuration module for the Baloo search framework"
HOMEPAGE="https://gitlab.com/baloo-kcmadv/baloo-kcmadv"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE=""

DEPEND="
	$(add_kdebase_dep baloo)
	$(add_kdebase_dep kfilemetadata)
	dev-libs/qjson
	dev-libs/xapian
"
RDEPEND="${DEPEND}"

src_prepare() {
	kde4-base_src_prepare

	if ! use handbook; then
		rm -r doc/ || die
	fi
}

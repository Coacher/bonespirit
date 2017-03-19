# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KDE_MINIMAL=4.13.0

inherit kde4-base vcs-snapshot

COMMIT_ID="35991b911c228731726d119084936a40ebc1447d"

DESCRIPTION="Advanced configuration module for the Baloo file indexer"
HOMEPAGE="https://gitlab.com/baloo-kcmadv/baloo-kcmadv"
SRC_URI="https://gitlab.com/${PN}/${PN}/repository/archive.tar.gz?ref=${COMMIT_ID} -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE=""

DEPEND="
	kde-frameworks/baloo:4[-minimal(-)]
	kde-frameworks/kfilemetadata:4
	dev-libs/qjson
	dev-libs/xapian
"
RDEPEND="${DEPEND}"

src_prepare() {
	kde4-base_src_prepare

	# Disable unconditional docbook documentation build.
	cmake_comment_add_subdirectory doc
}

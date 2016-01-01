# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

KDE_MINIMAL=4.13.0
GIT_SHA1="35991b911c228731726d119084936a40ebc1447d"

inherit kde4-base vcs-snapshot

DESCRIPTION="Alternative configuration module for the Baloo search framework"
HOMEPAGE="https://gitlab.com/baloo-kcmadv/baloo-kcmadv"
SRC_URI="https://gitlab.com/${PN}/${PN}/repository/archive.tar.gz?ref=${GIT_SHA1} -> ${P}.tar.gz"

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

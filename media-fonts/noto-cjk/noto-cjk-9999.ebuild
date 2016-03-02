# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font git-r3

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://www.google.com/get/noto/help/cjk/"
EGIT_REPO_URI="git://github.com/googlei18n/noto-cjk.git"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

DOCS="HISTORY NEWS README.formats"

FONT_SUFFIX="otf"
FONT_S="${S}"
FONT_CONF=( "${FILESDIR}/59-${PN}.conf" )

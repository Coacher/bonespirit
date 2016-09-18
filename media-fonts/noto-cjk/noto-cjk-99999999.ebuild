# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font git-r3

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://www.google.com/get/noto/help/cjk/ https://github.com/googlei18n/noto-cjk"
EGIT_REPO_URI="git://github.com/googlei18n/${PN}.git"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

DOCS="HISTORY README.formats"

FONT_SUFFIX="otf"
FONT_CONF=( "${FILESDIR}/59-${PN}.conf" )
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit font git-r3

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://www.google.com/get/noto/"
EGIT_REPO_URI="git://github.com/googlei18n/noto-fonts.git"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="binchecks strip"

DOCS="FAQ.md NEWS README.md"

FONT_SUFFIX="ttf"
FONT_S="${S}/unhinted"

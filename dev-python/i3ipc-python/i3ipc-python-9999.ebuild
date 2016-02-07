# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1 git-r3

DESCRIPTION="An improved Python library to control i3wm"
HOMEPAGE="https://github.com/acrisci/i3ipc-python"
EGIT_REPO_URI="git://github.com/Coacher/${PN}.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="examples"

RDEPEND="virtual/python-enum34[${PYTHON_USEDEP}]"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

DOCS=( README.rst )

src_prepare() {
	# virtual/python-enum34 is the Gentoo analogue of enum-compat.
	sed -i -e "s/'enum-compat'//g" setup.py || die
	distutils-r1_src_prepare
}

src_install() {
	use examples && DOCS+=( examples/ )
	distutils-r1_src_install
}

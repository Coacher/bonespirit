# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit distutils-r1 git-r3

DESCRIPTION="An improved Python library to control i3wm"
HOMEPAGE="https://github.com/acrisci/i3ipc-python https://pypi.python.org/pypi/i3ipc"
EGIT_REPO_URI="git://github.com/acrisci/${PN}.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="
	virtual/python-enum34[${PYTHON_USEDEP}]
	x11-wm/i3
"

DOCS=( README.rst )

python_prepare_all() {
	# virtual/python-enum34 is the Gentoo equivalent of enum-compat.
	sed -i -e "s|'enum-compat'||g" setup.py || die
	distutils-r1_python_prepare_all
}

src_install() {
	use examples && DOCS+=( examples/ )
	distutils-r1_src_install
}

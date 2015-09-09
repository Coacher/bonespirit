# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit distutils-r1 git-r3

EGIT_REPO_URI="git://github.com/chrippa/${PN}.git"
EGIT_BRANCH="develop"

DESCRIPTION="CLI utility that extracts streams from various services and
pipes them into a video player of choice"
HOMEPAGE="http://docs.livestreamer.io/ https://github.com/chrippa/livestreamer"

# MIT license is used for docs only
LICENSE="BSD-2 MIT-with-advertising"
SLOT="0"
KEYWORDS=""
IUSE="doc test"

RDEPEND="
	>=dev-python/requests-1.0[${PYTHON_USEDEP}]
	dev-python/pycrypto[${PYTHON_USEDEP}]
	virtual/python-futures[${PYTHON_USEDEP}]
	virtual/python-singledispatch[${PYTHON_USEDEP}]
	~media-video/rtmpdump-${PV}
"
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? ( ${RDEPEND} )
"

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}

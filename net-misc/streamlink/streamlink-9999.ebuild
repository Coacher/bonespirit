# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5} )
PYTHON_REQ_USE='threads(+),xml(+)'

inherit distutils-r1 git-r3

DESCRIPTION="Extracts streams from various services and pipes them into a video player"
HOMEPAGE="https://streamlink.github.io/"
EGIT_REPO_URI=( {https,git}://github.com/${PN}/${PN}.git )

LICENSE="BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="
	dev-python/pycrypto[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	!=dev-python/requests-2.12.0[${PYTHON_USEDEP}]
	!=dev-python/requests-2.12.1[${PYTHON_USEDEP}]
	media-video/rtmpdump
	virtual/ffmpeg
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? (
		dev-python/docutils[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
	)
	test? ( ${RDEPEND} )
"

python_prepare_all() {
	# Remove pycryptodome dependency until it's added to the tree.
	sed -i -e '/pycryptodome/d' setup.py || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	esetup.py test
}

src_install() {
	use doc && HTML_DOCS=( docs/_build/html/. )
	distutils-r1_src_install
}
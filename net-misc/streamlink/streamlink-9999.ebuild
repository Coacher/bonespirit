# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6} )
PYTHON_REQ_USE='threads(+),xml(+)'

inherit distutils-r1 git-r3

DESCRIPTION="Extracts streams from various services and pipes them into a video player"
HOMEPAGE="https://streamlink.github.io/"
EGIT_REPO_URI="https://github.com/streamlink/streamlink.git"

LICENSE="BSD-2 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="
	dev-python/isodate[${PYTHON_USEDEP}]
	dev-python/pycountry[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/websocket-client[${PYTHON_USEDEP}]
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

python_configure_all() {
	# Avoid iso-639, iso3166 dependencies since we use pycountry.
	export STREAMLINK_USE_PYCOUNTRY=1
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

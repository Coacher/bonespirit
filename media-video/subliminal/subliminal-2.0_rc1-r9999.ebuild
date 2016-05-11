# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1

MY_PV="${PV/_/-}"

DESCRIPTION="Python library to search and download subtitles"
HOMEPAGE="https://github.com/Diaoul/subliminal https://pypi.python.org/pypi/subliminal"
SRC_URI="https://github.com/Diaoul/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="
	>=dev-python/guessit-2.0.1[${PYTHON_USEDEP}]
	>=dev-python/babelfish-0.5.2[${PYTHON_USEDEP}]
	>=dev-python/enzyme-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/beautifulsoup-4.2.0:4[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0.1[${PYTHON_USEDEP}]
	>=dev-python/click-4.0[${PYTHON_USEDEP}]
	>=dev-python/dogpile-cache-0.5.4[${PYTHON_USEDEP}]
	>=dev-python/stevedore-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/chardet-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/pysrt-1.0.1[${PYTHON_USEDEP}]
	>=dev-python/six-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/appdirs-1.3[${PYTHON_USEDEP}]
	>=dev-python/rarfile-2.7[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	virtual/python-futures[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	test? (
		>=dev-python/vcrpy-1.6.1[${PYTHON_USEDEP}]
		dev-python/pytest-cov[${PYTHON_USEDEP}]
		dev-python/pytest-runner[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/sympy[${PYTHON_USEDEP}]
		python_targets_python2_7? (
			dev-python/mock[$(python_gen_usedep 'python2*')]
		)
	)
"

# Tests require network and severely broken too.
RESTRICT=test

S="${WORKDIR}/${PN}-${MY_PV}"

python_prepare_all() {
	# Disable code checkers as they require unavailable dependencies.
	sed -i -e 's/--\(pep8\|flakes\)//g' pytest.ini || die
	sed -i -e "s/'pytest-\(pep8\|flakes\)',//g" setup.py || die

	# Disable unconditional dependency on dev-python/pytest-runner.
	sed -i -e "s|'pytest-runner'||g" setup.py || die

	distutils-r1_python_prepare_all
}

python_test() {
	esetup.py test
}
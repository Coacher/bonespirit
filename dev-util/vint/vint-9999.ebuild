# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1 git-r3

DESCRIPTION="Lint tool for Vim script Language"
HOMEPAGE="https://github.com/Kuniwak/vint"
EGIT_REPO_URI="git://github.com/Kuniwak/${PN}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="
	>=dev-python/ansicolor-0.2.4[${PYTHON_USEDEP}]
	>=dev-python/chardet-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-3.11[${PYTHON_USEDEP}]
	virtual/python-pathlib[${PYTHON_USEDEP}]
	python_targets_python2_7? (
		>=dev-python/enum34-1.0.4[$(python_gen_usedep 'python2*')]
	)
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		>=dev-python/coverage-3.7.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-2.6.4[${PYTHON_USEDEP}]
		>=dev-python/pytest-cov-1.8.1[${PYTHON_USEDEP}]
		python_targets_python2_7? (
			>=dev-python/mock-1.0.1[$(python_gen_usedep 'python2*')]
		)
	)
"

DOCS=( README.rst )

PATCHES=( "${FILESDIR}/${PN}-exclude-tests-recursively.patch" )

python_test() {
	py.test -v || die "Testing failed with ${EPYTHON}"
}

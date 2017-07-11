# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Track https://github.com/MestreLion/git-tools/issues/23 for Python-3 support
PYTHON_COMPAT=( python2_7 )

inherit python-r1 git-r3

DESCRIPTION="Assorted git-related scripts"
HOMEPAGE="https://github.com/MestreLion/git-tools/"
EGIT_REPO_URI=( {https,git}://github.com/MestreLion/${PN}.git )

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	>=app-shells/bash-4
	dev-vcs/git
"

src_compile() {
	:;
}

src_install() {
	SCRIPTS_BASH="git-branches-rename git-clone-subset \
		git-find-uncommitted-repos git-rebase-theirs git-strip-merge"
	dobin ${SCRIPTS_BASH}

	SCRIPTS_PYTHON="git-restore-mtime"
	dobin ${SCRIPTS_PYTHON}
	for p in ${SCRIPTS_PYTHON}; do
		python_replicate_script "${ED}"usr/bin/${p}
	done

	# Make it possible to use the tools as 'git $TOOLNAME'
	for x in ${SCRIPTS_BASH} ${SCRIPTS_PYTHON}; do
		dosym ../../bin/${x} /usr/libexec/git-core/${x}
	done

	einstalldocs
	doman man1/*.1
}

# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit eutils python-r1

DESCRIPTION="Assorted git-related scripts"
HOMEPAGE="https://github.com/MestreLion/git-tools/"
EGIT_REPO_URI=( {https,git}://github.com/MestreLion/${PN}.git )

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=app-shells/bash-4
	dev-vcs/git
"

src_compile() {
	:;
}

src_install() {
	SCRIPTS_BASH="git-branches-rename git-clone-subset git-find-uncommitted-repos git-rebase-theirs git-strip-merge"
	SCRIPTS_PYTHON="git-restore-mtime"
	dobin $SCRIPTS_BASH
	dobin $SCRIPTS_PYTHON
	for p in $SCRIPTS_PYTHON ; do
		python_replicate_script "${ED}"usr/bin/$p
	done
	# Make it possible to use the tools as 'git $TOOLNAME'
	for i in $SCRIPTS_BASH $SCRIPTS_PYTHON ; do
		dosym /usr/bin/$i /usr/libexec/git-core/$i
	done
	einstalldocs
}

# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

VIM_PLUGIN_HELPFILES="${PN}.txt"

inherit vim-plugin git-r3

DESCRIPTION="vim plugin: plugin manager for Vim"
HOMEPAGE="https://github.com/VundleVim/Vundle.vim"
EGIT_REPO_URI="https://github.com/VundleVim/Vundle.vim.git"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-vcs/git
	|| ( net-misc/curl net-misc/wget )
"

src_prepare() {
	default_src_prepare
	rm -r test/ LICENSE-MIT.txt || die
}

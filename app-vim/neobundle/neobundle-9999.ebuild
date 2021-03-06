# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

VIM_PLUGIN_HELPFILES="${PN}.txt"

inherit vim-plugin git-r3

DESCRIPTION="vim plugin: next generation Vim package manager"
HOMEPAGE="https://github.com/Shougo/neobundle.vim"
EGIT_REPO_URI="https://github.com/Shougo/neobundle.vim.git"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-vcs/git
	|| ( net-misc/curl net-misc/wget )
"

src_prepare() {
	default_src_prepare
	rm -r bin/ test/ LICENSE-MIT.txt Makefile || die
}

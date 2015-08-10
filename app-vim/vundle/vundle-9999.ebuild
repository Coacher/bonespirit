# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vim-plugin git-r3

EGIT_REPO_URI="git://github.com/gmarik/${PN}.vim.git"

DESCRIPTION="vim plugin: plugin manager for Vim"
HOMEPAGE="https://github.com/gmarik/Vundle.vim"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-vcs/git
	net-misc/curl"

VIM_PLUGIN_HELPFILES="${PN}.txt"

src_prepare() {
	rm -r test/ LICENSE-MIT.txt || die
}

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vim-plugin git-r3

EGIT_REPO_URI="git://github.com/Shougo/${PN}.vim.git"

DESCRIPTION="vim plugin: include completion framework for neocomplete"
HOMEPAGE="https://github.com/Shougo/neoinclude.vim"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

VIM_PLUGIN_HELPFILES="${PN}.txt"

src_prepare() {
	rm -r rplugin/ || die
}

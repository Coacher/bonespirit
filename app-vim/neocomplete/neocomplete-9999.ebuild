# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vim-plugin git-r3

EGIT_REPO_URI="git://github.com/Shougo/${PN}.vim.git"

DESCRIPTION="vim plugin: next generation auto completion framework"
HOMEPAGE="https://github.com/Shougo/neocomplete.vim"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

RDEPEND="!app-vim/neocomplcache
	|| (
		>=app-editors/vim-7.3.885[lua]
		>=app-editors/gvim-7.3.885[lua]
	)"

VIM_PLUGIN_HELPFILES="${PN}.txt"

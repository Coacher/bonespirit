# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vim-plugin

DESCRIPTION="vim plugin: next generation auto completion framework"
HOMEPAGE="https://github.com/Shougo/neocomplete.vim"
SRC_URI="https://github.com/Shougo/${PN}.vim/archive/ver.${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

RDEPEND="!app-vim/neocomplcache
	|| (
		>=app-editors/vim-7.3.885[lua]
		>=app-editors/gvim-7.3.885[lua]
	)"

VIM_PLUGIN_HELPFILES="${PN}.txt"

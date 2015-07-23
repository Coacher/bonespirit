# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vim-plugin git-r3

EGIT_REPO_URI="git://github.com/hynek/vim-${PN}.git"

DESCRIPTION="vim plugin: nicer Python indentation style for Vim"
HOMEPAGE="https://github.com/hynek/vim-python-pep8-indent"
LICENSE="CC0-1.0"
KEYWORDS="~amd64 ~x86"

VIM_PLUGIN_MESSAGES="filetype"

src_prepare() {
	rm -r spec/ Gemfile COPYING.txt || die
}

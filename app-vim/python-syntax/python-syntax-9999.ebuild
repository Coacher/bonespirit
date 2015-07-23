# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vim-plugin git-r3

EGIT_REPO_URI="git://github.com/hdima/${PN}.git"

DESCRIPTION="vim plugin: enhanced version of the original Python syntax highlighting"
HOMEPAGE="https://github.com/hdima/python-syntax"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE="extras"

VIM_PLUGIN_MESSAGES="filetype"

src_prepare() {
	rm test.py LICENSE || die
	if ! use extras; then
		rm -r folding-ideas/ || die
	fi
}

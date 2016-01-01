# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vim-plugin git-r3

EGIT_REPO_URI="git://github.com/jnurmine/Zenburn.git"

DESCRIPTION="vim plugin: low-contrast color scheme for Vim"
HOMEPAGE="https://github.com/jnurmine/Zenburn"
LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	rm zb-vimball.txt || die
}

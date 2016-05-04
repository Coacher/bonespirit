# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit vim-plugin git-r3

DESCRIPTION="vim plugin: low-contrast color scheme for Vim"
HOMEPAGE="http://kippura.org/zenburnpage/ https://github.com/jnurmine/Zenburn"
EGIT_REPO_URI="git://github.com/jnurmine/Zenburn.git"

LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	default_src_prepare
	rm zb-vimball.txt || die
}

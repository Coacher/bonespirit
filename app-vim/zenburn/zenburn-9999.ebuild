# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vim-plugin git-r3
MY_PN="Zenburn"
EGIT_REPO_URI="git://github.com/jnurmine/${MY_PN}.git"

DESCRIPTION="vim colorscheme: a low-contrast color scheme for Vim"
HOMEPAGE="https://github.com/jnurmine/Zenburn"
LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	rm zb-vimball.txt || die
}

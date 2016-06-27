# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit bash-completion-r1 git-r3

DESCRIPTION="Bash completion for the mpv video player"
HOMEPAGE="https://2ion.github.io/mpv-bash-completion/"
EGIT_REPO_URI="git://github.com/2ion/${PN}.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="luajit"

COMMON_DEPEND="media-video/mpv[cli]"
DEPEND="${COMMON_DEPEND}
	!luajit? ( dev-lang/lua:* )
	luajit? ( dev-lang/luajit:2 )
"
RDEPEND="${COMMON_DEPEND}
	>=app-shells/bash-completion-2.3-r1
"

src_compile() {
	$(usex luajit 'luajit' 'lua') gen.lua > ${PN} || die
}

src_install() {
	einstalldocs
	newbashcomp ${PN} mpv
}

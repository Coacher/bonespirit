# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit bash-completion-r1 git-r3

DESCRIPTION="Bash completion for the mpv video player"
HOMEPAGE="https://2ion.github.io/mpv-bash-completion/"
EGIT_REPO_URI=( {https,git}://github.com/2ion/${PN}.git )

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="luajit"

COMMON_DEPEND=">=media-video/mpv-0.14.0[cli]"
RDEPEND="${COMMON_DEPEND}
	>=app-shells/bash-completion-2.3-r1
"
DEPEND="${COMMON_DEPEND}
	!luajit? ( dev-lang/lua:* )
	luajit? ( dev-lang/luajit:2 )
"

src_prepare() {
	default_src_prepare
	# Avoid 'mpv' make target that supports lua only.
	sed -i -e 's|check: mpv|check:|' Makefile || die
}

src_compile() {
	$(usex luajit 'luajit' 'lua') gen.lua > mpv || die
}

src_install() {
	dobashcomp mpv
	einstalldocs
}

pkg_postinst() {
	if ! has_version 'x11-apps/xrandr'; then
		echo
		elog "If you want completion of window sizes, please install 'x11-apps/xrandr'."
		echo
	fi
}

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vim-plugin flag-o-matic git-r3

EGIT_REPO_URI="git://github.com/Shougo/${PN}.vim.git"

DESCRIPTION="vim plugin: asynchronous execution library for Vim"
HOMEPAGE="https://github.com/Shougo/vimproc.vim"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

VIM_PLUGIN_HELPFILES="${PN}.txt"

src_prepare() {
	mv make_unix.mak Makefile || die
	rm -r test/ *.mak autoload/proc_w32.c tools/update-dll-mingw.bat || die
}

src_compile() {
	append-cflags -shared -fPIC

	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}"
}

src_install() {
	vim-plugin_src_install

	fperms 755 /usr/share/vim/vimfiles/autoload/vimproc_*.so
}

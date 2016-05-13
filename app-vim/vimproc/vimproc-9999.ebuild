# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

VIM_PLUGIN_HELPFILES="${PN}.txt"

inherit flag-o-matic toolchain-funcs vim-plugin git-r3

DESCRIPTION="vim plugin: asynchronous execution library for Vim"
HOMEPAGE="https://github.com/Shougo/vimproc.vim"
EGIT_REPO_URI="git://github.com/Shougo/${PN}.vim.git"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	default_src_prepare
	mv make_unix.mak Makefile || die
	rm -r *.mak *.yml lib/.gitkeep test/ tools/*.bat || die
}

src_compile() {
	append-cflags -fPIC -shared
	append-ldflags -lutil
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
	# Don't install C sources.
	rm -r src/ || die

	vim-plugin_src_install

	# Make the installed shared library executable.
	fperms a+x /usr/share/vim/vimfiles/lib/${PN}_*.so
}

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
PYTHON_REQ_USE='threads'

inherit eutils fdo-mime flag-o-matic prefix python-r1 git-r3

DESCRIPTION="Qt GUI version of the Vim text editor"
HOMEPAGE="https://bitbucket.org/equalsraf/vim-qt/wiki/Home"
EGIT_REPO_URI=(
	"https://bitbucket.org/equalsraf/${PN}.git"
	"https://github.com/equalsraf/${PN}.git"
)

LICENSE="vim"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="acl cscope debug lua luajit lto nls perl python racket ruby"

RDEPEND="
	>=app-editors/vim-core-7.4.827[acl?]
	>=app-eselect/eselect-vi-1.1.8
	>=dev-qt/qtcore-4.7.0:4
	>=dev-qt/qtgui-4.7.0:4
	>=sys-libs/ncurses-5.2-r2:0=
	acl? ( kernel_linux? ( sys-apps/acl ) )
	cscope? ( dev-util/cscope )
	lua? (
		luajit? ( dev-lang/luajit:2 )
		!luajit? ( dev-lang/lua:0[deprecated] )
	)
	nls? ( virtual/libintl )
	perl? ( dev-lang/perl:= )
	python? ( ${PYTHON_DEPS} )
	racket? ( dev-scheme/racket )
	ruby? ( || ( dev-lang/ruby:2.2 dev-lang/ruby:2.1 dev-lang/ruby:2.0 ) )
"
DEPEND="${RDEPEND}
	dev-util/ctags
	sys-devel/autoconf
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"
REQUIRED_USE="
	luajit? ( lua )
	python? (
		|| ( $(python_gen_useflags '*') )
		?? ( $(python_gen_useflags 'python2*') )
		?? ( $(python_gen_useflags 'python3*') )
	)
"

pkg_setup() {
	# Prevent locale brokenness
	export LC_COLLATE="C"
}

src_prepare() {
	# Read vimrc from /etc/vim/
	echo "#define SYS_VIMRC_FILE \"${EPREFIX}/etc/vim/vimrc\"" >> "${S}/src/feature.h"
}

src_configure() {
	if use lto; then
		LDFLAGS_OLD="$LDFLAGS"
		local LDFLAGS="${LDFLAGS} -fno-lto -fno-use-linker-plugin"
	fi

	use debug && append-flags "-DDEBUG"

	local myconf=(
		--with-features=huge
		--disable-gpm
		--enable-multibyte
		$(use_enable acl)
		$(use_enable cscope)
		$(use_enable lua luainterp)
		$(use_enable nls)
		$(use_enable perl perlinterp)
		$(use_enable racket mzschemeinterp)
		$(use_enable ruby rubyinterp)
		$(use_with luajit)
	)

	if ! use cscope; then
		sed -i -e '/# define FEAT_CSCOPE/d' src/feature.h || die
	fi

	# Keep prefix env contained within the EPREFIX
	use prefix && myconf+=" --without-local-dir"

	if use python; then
		py_add_interp() {
			local v

			[[ ${EPYTHON} == python3* ]] && v=3
			myconf+=(
				--enable-python${v}interp
				vi_cv_path_python${v}="${PYTHON}"
			)
		}

		python_foreach_impl py_add_interp
	else
		myconf+=(
			--disable-pythoninterp
			--disable-python3interp
		)
	fi

	econf \
		--with-modified-by="Gentoo-${PVR}" \
		--with-vim-name=qvim \
		--enable-gui=qt \
		"${myconf[@]}"

	if use lto; then
		LDFLAGS="${LDFLAGS_OLD}"
		sed -i -e "s/-fno-lto -fno-use-linker-plugin//g" src/auto/config.mk || die
	fi
}

src_install() {
	dobin src/qvim
	dosym qvim /usr/bin/qvimdiff

	dodir /usr/share/man/man1
	echo ".so vim.1" > "${ED}"/usr/share/man/man1/qvim.1
	echo ".so vimdiff.1" > "${ED}"/usr/share/man/man1/qvimdiff.1

	# See https://bitbucket.org/equalsraf/vim-qt/issue/93/include-desktop-file-in-source
	newmenu "${FILESDIR}/${PN}.desktop" ${PN}.desktop
	doicon -s 64 "src/qt/icons/${PN}.png"
}

pkg_postinst() {
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_mime_database_update
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
VIM_VERSION=8.0

PYTHON_COMPAT=( python{2_7,3_4,3_5} )
PYTHON_REQ_USE='threads(+)'

inherit bash-completion-r1 eutils flag-o-matic gnome2-utils prefix python-r1 user versionator vim-doc xdg-utils git-r3

DESCRIPTION="GUI version of the Vim text editor"
HOMEPAGE="http://www.vim.org/ https://github.com/vim/vim"
EGIT_REPO_URI=( {https,git}://github.com/vim/vim.git )

LICENSE="vim"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="acl cscope debug gtk3 lua luajit netbeans nls perl python racket ruby selinux session tcl"

RDEPEND="
	~app-editors/vim-core-${PV}[acl?]
	app-eselect/eselect-vi
	sys-libs/ncurses:0=
	x11-libs/libX11
	x11-libs/libXt
	acl? ( virtual/acl )
	cscope? ( dev-util/cscope )
	!gtk3? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	lua? (
		!luajit? ( dev-lang/lua:=[deprecated] )
		luajit? ( dev-lang/luajit:2 )
	)
	nls? ( virtual/libintl )
	perl? ( dev-lang/perl:= )
	python? ( ${PYTHON_DEPS} )
	racket? ( dev-scheme/racket )
	ruby? ( dev-lang/ruby:= )
	selinux? ( sys-libs/libselinux )
	session? (
		x11-libs/libICE
		x11-libs/libSM
	)
	tcl? ( dev-lang/tcl:0= )
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

src_prepare() {
	default_src_prepare

	# Use awk instead of nawk.
	sed -i \
		-e "1s|.*|#!${EPREFIX}/usr/bin/awk -f|" \
		runtime/tools/mve.awk || die

	# Fix NeXT misdetection caused by dev-libs/9libs. See Gentoo bug 43885.
	sed -i -e 's|libc\.h||' src/configure.ac || die

	# Fix EOF misdetection on SPARC. See Gentoo bug 66162.
	find "${S}" -name '*.c' | while read -r file; do echo >> "${file}"; done

	# Fix configure failure. See Gentoo bug 360217.
	if version_is_at_least 7.3.122; then
		cp src/config.mk.dist src/auto/config.mk || die
	fi

	# Don't create symlinks that are managed by app-eselect/eselect-vi.
	sed -i \
		-e '/ln -s.*\<\(ex\|view\)name\.1$/d' \
		src/installml.sh || die

	# Read vimrc and gvimrc from /etc/vim.
	echo "#define SYS_VIMRC_FILE \"${EPREFIX}/etc/vim/vimrc\"" >> src/feature.h || die
	echo "#define SYS_GVIMRC_FILE \"${EPREFIX}/etc/vim/gvimrc\"" >> src/feature.h || die

	gnome2_environment_reset
}

src_configure() {
	# Remove flags that cause problems.
	filter-flags -funroll-all-loops		# See Gentoo bugs 37354, 57859.
	replace-flags -O[3-9] -O2			# See Gentoo bug 76331.

	# Prevent the following chain of events:
	# (1) Notice configure.ac is newer than auto/configure due to sed;
	# (2) Rebuild auto/configure;
	# (3) Notice auto/configure is newer than auto/config.mk;
	# (4) Run ./configure (with incorrect args) to remake auto/config.mk.
	# See Gentoo bug 18245.
	sed -i -e 's| auto/config\.mk:|:|' src/Makefile || die
	rm src/auto/configure || die
	emake -j1 -C src autoconf

	# Disable built-in binary stripping. Let Portage do it.
	export ac_cv_prog_STRIP="$(type -P true)"

	# Help Vim figure out tty group/permissions.
	export vim_cv_tty_group=$(egetent group tty | cut -d ':' -f 3)
	export vim_cv_tty_mode=0620

	use debug && append-flags -DDEBUG

	local myeconfargs=(
		--with-features=huge
		--enable-multibyte
		--disable-darwin
		--disable-gpm
		--with-x
		$(use_enable acl)
		$(use_enable cscope)
		$(use_enable lua luainterp)
		$(use_enable netbeans)
		$(use_enable nls)
		$(use_enable perl perlinterp)
		$(use_enable racket mzschemeinterp)
		$(use_enable ruby rubyinterp)
		$(use_enable selinux)
		$(use_enable session xsmp)
		$(use_enable tcl tclinterp)
		$(use_with luajit)
	)

	if use python; then
		add_python_interp() {
			local v

			[[ ${EPYTHON} == python3* ]] && v=3
			myeconfargs+=(
				--enable-python${v}interp
				vi_cv_path_python${v}="${PYTHON}"
			)
		}

		python_foreach_impl add_python_interp
	else
		myeconfargs+=(
			--disable-pythoninterp
			--disable-python3interp
		)
	fi

	if ! use gtk3; then
		myeconfargs+=(
			--enable-gtk2-check
			--enable-gui=gtk2
		)
	else
		myeconfargs+=(
			--enable-gtk3-check
			--enable-gui=gtk3
		)
	fi

	# Fix Lua detection on Prefix. See Gentoo bug 533362.
	use lua && myeconfargs+=(--with-lua-prefix="${EPREFIX}/usr")

	# Fix cscope misconfiguration caused by 'features=huge'.
	# See Gentoo bug 62465.
	if ! use cscope; then
		sed -i -e '/# define FEAT_CSCOPE/d' src/feature.h || die
	fi

	# Keep prefix environment contained within the EPREFIX.
	use prefix && myeconfargs+=(--without-local-dir)

	econf \
		--with-modified-by="Gentoo-${PVR}" \
		--with-vim-name="${PN}" \
		"${myeconfargs[@]}"
}

src_compile() {
	# This allows 'emake' to be used.
	emake -j1 -C src auto/osdef.h objects

	emake
}

src_test() {
	# Prevent gvim from connecting to X.
	# See ':help gui-x11-start' in Vim for more info.
	ln -s "${S}"/src/${PN} "${S}"/src/testvim || die
	sed -i -e "s|\.\./vim|${S}/src/testvim|" src/testdir/test49.vim || die

	unset DISPLAY
	emake -j1 VIMPROG="${S}/src/testvim" -C src/testdir nongui
}

src_install() {
	dobin src/${PN}

	dosym ${PN} /usr/bin/gvimdiff
	dosym ${PN} /usr/bin/evim
	dosym ${PN} /usr/bin/eview
	dosym ${PN} /usr/bin/gview
	dosym ${PN} /usr/bin/rgvim
	dosym ${PN} /usr/bin/rgview

	dodir /usr/share/man/man1
	echo '.so vim.1' > "${ED}"usr/share/man/man1/gvim.1 || die
	echo '.so vim.1' > "${ED}"usr/share/man/man1/gview.1 || die
	echo '.so vimdiff.1' > "${ED}"usr/share/man/man1/gvimdiff.1 || die

	local size
	for size in 16 32 48; do
		newicon -s ${size} runtime/vim${size}x${size}.png ${PN}.png
	done
	doicon -s scalable "${FILESDIR}/${PN}.svg"
	domenu runtime/${PN}.desktop

	insinto /etc/vim
	newins "${FILESDIR}/gvimrc-r1" gvimrc
	eprefixify "${ED}"etc/vim/gvimrc

	newbashcomp "${FILESDIR}/${PN}-completion" ${PN}
	bashcomp_alias ${PN} evim eview gview gvimdiff rgvim rgview
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	eselect vi update --if-unset
	update_vim_helptags
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	eselect vi update --if-unset
	update_vim_helptags
}

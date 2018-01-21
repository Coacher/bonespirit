# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
VIM_VERSION=8.0

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )
PYTHON_REQ_USE='threads(+)'

inherit bash-completion-r1 flag-o-matic gnome2-utils prefix python-r1 user versionator vim-doc git-r3

DESCRIPTION="Highly configurable text editor built to enable efficient text editing"
HOMEPAGE="http://www.vim.org/ https://github.com/vim/vim"
EGIT_REPO_URI="https://github.com/vim/vim.git"

LICENSE="vim"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="X acl cscope debug gpm lua luajit minimal netbeans nls perl python racket ruby selinux session tcl"

RDEPEND="
	app-eselect/eselect-vi
	sys-libs/ncurses:0=
	acl? ( virtual/acl )
	cscope? ( dev-util/cscope )
	gpm? ( sys-libs/gpm )
	lua? (
		!luajit? ( dev-lang/lua:=[deprecated] )
		luajit? ( dev-lang/luajit:2 )
	)
	!minimal? (
		~app-editors/vim-core-${PV}[acl?]
		dev-util/ctags
	)
	nls? ( virtual/libintl )
	perl? ( dev-lang/perl:= )
	python? ( ${PYTHON_DEPS} )
	racket? ( dev-scheme/racket )
	ruby? ( dev-lang/ruby:= )
	selinux? ( sys-libs/libselinux )
	tcl? ( dev-lang/tcl:0= )
	X? (
		x11-libs/libX11
		x11-libs/libXt
		session? (
			x11-libs/libICE
			x11-libs/libSM
		)
	)
"
DEPEND="${RDEPEND}
	sys-devel/autoconf
	nls? ( sys-devel/gettext )
"

REQUIRED_USE="
	luajit? ( lua )
	session? ( X )
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
	sed -i -e 's|libc\.h ||' src/configure.ac || die

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

	if use minimal; then
		local myeconfargs=(
			--with-features=tiny
			--disable-multibyte
			--disable-darwin
			--disable-selinux
			--disable-xsmp
			--disable-luainterp
			--disable-mzschemeinterp
			--disable-perlinterp
			--disable-pythoninterp
			--disable-python3interp
			--disable-tclinterp
			--disable-rubyinterp
			--disable-cscope
			--disable-netbeans
			--disable-acl
			--disable-gpm
			--disable-nls
			--enable-gui=no
			--without-x
		)
	else
		use debug && append-flags -DDEBUG

		local myeconfargs=(
			--with-features=huge
			--enable-multibyte
			--disable-darwin
			--enable-gui=no
			$(use_enable acl)
			$(use_enable cscope)
			$(use_enable gpm)
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
			$(use_with X x)
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

		# Fix Lua detection on Prefix. See Gentoo bug 533362.
		use lua && myeconfargs+=(--with-lua-prefix="${EPREFIX}/usr")

		# Fix cscope misconfiguration caused by 'features=huge'.
		# See Gentoo bug 62465.
		if ! use cscope; then
			sed -i -e '/# define FEAT_CSCOPE/d' src/feature.h || die
		fi
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
	emake -C src auto/osdef.h objects

	emake
}

src_test() {
	unset DISPLAY
	emake -j1 -C src/testdir nongui
}

src_install() {
	dobin src/${PN}

	dosym ${PN} /usr/bin/vimdiff
	dosym ${PN} /usr/bin/rvim
	dosym ${PN} /usr/bin/rview

	newbashcomp "${FILESDIR}/${PN}-completion" ${PN}
	bashcomp_alias ${PN} ex vi view rvim rview vimdiff
}

pkg_postinst() {
	eselect vi update --if-unset
	update_vim_helptags
}

pkg_postrm() {
	eselect vi update --if-unset
	update_vim_helptags
}

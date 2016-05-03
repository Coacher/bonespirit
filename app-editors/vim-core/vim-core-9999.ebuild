# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
VIM_VERSION=7.4

inherit bash-completion-r1 eutils flag-o-matic gnome2-utils prefix user versionator vim-doc git-r3

DESCRIPTION="Vim and GVim shared files"
HOMEPAGE="http://www.vim.org/ https://github.com/vim/vim"
EGIT_REPO_URI="git://github.com/vim/vim.git"

LICENSE="vim"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="acl minimal nls"

DEPEND="sys-devel/autoconf"
PDEPEND="!minimal? ( app-vim/gentoo-syntax )"

src_prepare() {
	default

	# Use awk instead of nawk.
	sed -i -e \
		"1s|.*|#!${EPREFIX}/usr/bin/awk -f|" \
		"${S}"/runtime/tools/mve.awk || die

	# Fix NeXT misdetection caused by dev-libs/9libs. See Gentoo bug 43885.
	sed -i -e 's|libc\.h||' "${S}"/src/configure.in || die

	# Fix EOF misdetection on SPARC. See Gentoo bug 66162.
	find "${S}" -name '*.c' | while read -r file; do echo >> "${file}"; done

	# Fix configure failure. See Gentoo bug 360217.
	if version_is_at_least 7.3.122; then
		cp "${S}"/src/config.mk.dist "${S}"/src/auto/config.mk || die
	fi

	# Don't create symlinks that are managed by app-eselect/eselect-vi.
	sed -i \
		-e '/ln -s.*\<\(ex\|view\)name\.1$/d' \
		"${S}"/src/installml.sh || die

	# Read vimrc and gvimrc from /etc/vim.
	echo "#define SYS_VIMRC_FILE \"${EPREFIX}/etc/vim/vimrc\"" >> "${S}"/src/feature.h || die
	echo "#define SYS_GVIMRC_FILE \"${EPREFIX}/etc/vim/gvimrc\"" >> "${S}"/src/feature.h || die

	gnome2_environment_reset
}

src_configure() {
	# Remove flags that cause problems.
	filter-flags -funroll-all-loops		# See Gentoo bugs 37354, 57859.
	replace-flags -O3 -O2				# See Gentoo bug 76331.

	# Prevent the following chain of events:
	# (1) Notice configure.in is newer than auto/configure due to sed;
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

	local myeconfargs=(
		--disable-darwin
		--disable-selinux
		--disable-luainterp
		--disable-mzschemeinterp
		--disable-perlinterp
		--disable-pythoninterp
		--disable-python3interp
		--disable-tclinterp
		--disable-rubyinterp
		--disable-gpm
		--enable-gui=no
		--without-x
		$(use_enable acl)
		$(use_enable nls)
	)

	# Keep prefix environment contained within the EPREFIX.
	use prefix && myeconfargs+=(--without-local-dir)

	econf \
		--with-modified-by="Gentoo-${PVR}" \
		"${myeconfargs[@]}"
}

src_compile() {
	# This allows 'emake tools' to be used.
	emake -j1 -C src auto/osdef.h objects

	emake tools
}

src_test() { :; }

src_install() {
	local vimfiles=/usr/share/vim/vim${VIM_VERSION/.}

	dodir /usr/{bin,share/{man/man1,vim}}

	emake \
		-C src \
		installruntime \
		installmanlinks \
		installmacros \
		installtutorbin \
		installtutor \
		installtools \
		install-languages \
		install-icons \
		DESTDIR="${D}" \
		BINDIR="${EPREFIX}/usr/bin" \
		MANDIR="${EPREFIX}/usr/share/man" \
		DATADIR="${EPREFIX}/usr/share"

	keepdir ${vimfiles}/keymap

	# Default vimrc is installed by vim-core as it applies to Vim and GVim.
	insinto /etc/vim/
	newins "${FILESDIR}/vimrc-r4" vimrc
	eprefixify "${ED}"etc/vim/vimrc

	newbashcomp "${FILESDIR}/xxd-completion" xxd

	if use minimal; then
		# Remove non-critical files to save some space. See Gentoo bug 65144.
		eshopts_push -s extglob

		rm -r "${ED}${vimfiles}"/{compiler,doc,ftplugin,indent} || die
		rm -r "${ED}${vimfiles}"/{macros,print,tools,tutor} || die
		rm "${ED}"usr/bin/vimtutor || die

		local keep_colors="default"
		ignore=$(rm "${ED}${vimfiles}"/colors/!(${keep_colors}).vim || die)

		local keep_syntax="conf|crontab|fstab|inittab|resolv|sshdconfig|syntax|nosyntax|synload"
		ignore=$(rm "${ED}${vimfiles}"/syntax/!(${keep_syntax}).vim || die)

		eshopts_pop
	fi

	# Remove files that pose a security threat. See Gentoo bug 77841.
	# Some of these files don't exist in modern Vim anymore.
	rm -f "${ED}${vimfiles}"/tools/{vimspell.sh,tcltags} || die
}

pkg_postinst() {
	update_vim_helptags
}

pkg_postrm() {
	update_vim_helptags
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF=1

inherit autotools-utils git-r3

DESCRIPTION="Programmable completion functions for bash"
HOMEPAGE="https://github.com/scop/bash-completion"
EGIT_REPO_URI="git://github.com/scop/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	!app-eselect/eselect-bashcomp
	>=app-shells/bash-4.3_p30-r1
"
PDEPEND=">=app-shells/gentoo-bashcomp-20140911"

# Tests require an interactive shell. See Gentoo bug 477066.
RESTRICT="test"

DOCS=( AUTHORS CHANGES README.md )

# List unwanted completions to be removed later:
STRIP_COMPLETIONS=(
	# Slackware completions;
	explodepkg installpkg makepkg pkgtool removepkg sbopkg slackpkg slapt-get slapt-src upgradepkg

	# Debian completions;
	apt-build apt-cache apt-get aptitude bts dselect ifup ifdown ifstatus querybts reportbug

	# FreeBSD completions;
	freebsd-update kldload kldunload pkg_deinstall pkg_delete pkg_info portinstall portsnap portupgrade

	# Solaris completions;
	pkg-get pkgadd pkgrm pkgutil svcadm

	# Fedora completions;
	koji arm-koji ppc-koji s390-koji sparc-koji

	# Completions installed in app-editors/vim-core;
	xxd

	# Symlinks to deprecated completions.
	hd ncal
)

src_prepare() {
	# Update the build system with Gentoo paths.
	sed -i \
		-e 's|profile\.d|bash/bashrc.d|' \
		-e 's|\<datadir\>|libdir|g' \
		Makefile.am || die

	# Fix broken completions.
	sed -i -e 's|0..3|0..5|' completions/aclocal || die
	sed -i -e 's|\<mpv\>||' completions/Makefile.am || die

	autotools-utils_src_prepare
}

src_install() {
	# Workaround race conditions. See Gentoo bug 526996.
	mkdir -p "${ED}"/usr/share/${PN}/{completions,helpers} || die

	autotools-utils_src_install

	# Remove unwanted completions.
	local file
	for file in "${STRIP_COMPLETIONS[@]}"; do
		rm "${ED}/usr/share/${PN}/completions/${file}" || die
	done
	# Remove deprecated completions (moved to other packages).
	rm "${ED}"/usr/share/${PN}/completions/_* || die
}

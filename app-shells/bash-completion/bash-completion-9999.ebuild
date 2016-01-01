# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF=1

inherit autotools-utils versionator git-r3

DESCRIPTION="Programmable Completion for bash"
HOMEPAGE="https://bash-completion.alioth.debian.org/"
EGIT_REPO_URI="git://anonscm.debian.org/${PN}/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	!app-eselect/eselect-bashcomp
	>=app-shells/bash-4.3_p30-r1
"
DEPEND="app-arch/xz-utils"
PDEPEND=">=app-shells/gentoo-bashcomp-20140911"

# Disable tests because of interactive shell wrt bug #477066
RESTRICT="test"

DOCS=( AUTHORS CHANGES README )

PATCHES=( "${FILESDIR}/${PN}-blacklist-support.patch" )

# List unwanted completions to be removed later
STRIP_COMPLETIONS=(
	# Slackware completions
	explodepkg installpkg makepkg pkgtool removepkg sbopkg slackpkg slapt-get slapt-src upgradepkg

	# Debian completions
	apt-build apt-cache apt-get aptitude bts dselect ifup ifdown ifstatus querybts reportbug

	# FreeBSD completions
	freebsd-update kldload kldunload pkg_deinstall pkg_delete pkg_info portinstall portsnap portupgrade

	# Solaris completions
	pkg-get pkgadd pkgrm pkgutil svcadm

	# Fedora completions
	koji arm-koji ppc-koji s390-koji sparc-koji

	# Installed in app-editors/vim-core
	xxd

	# Symlinks to deprecated completions
	hd ncal
)

src_prepare() {
	sed -i -e 's%/profile.d%/bash/bashrc.d%' Makefile.am || die
	autotools-utils_src_prepare
}

src_configure() {
	autotools-utils_src_configure
}

src_install() {
	# Workaround race conditions wrt bug #526996
	mkdir -p "${ED}/usr/share/${PN}"/{completions,helpers} || die

	autotools-utils_src_install

	# Remove unwanted completions
	local file
	for file in "${STRIP_COMPLETIONS[@]}"; do
		rm "${ED}/usr/share/${PN}/completions/${file}" || die
	done
	# Remove deprecated completions (moved to other packages)
	rm "${ED}/usr/share/${PN}/completions"/_* || die

	insinto /usr/share/eselect/modules
	doins "${FILESDIR}/bashcomp.eselect"
	doman "${FILESDIR}/bashcomp.eselect.5"
}

pkg_postinst() {
	local v
	for v in ${REPLACING_VERSIONS}; do
		if ! version_is_at_least 2.1-r90 "${v}"; then
			ewarn "For bash-completion autoloader to work, all completions need to be installed"
			ewarn "in /usr/share/bash-completion/completions. You may need to rebuild packages"
			ewarn "that installed completions in the old location. You can do this using:"
			ewarn
			ewarn "$ find ${EPREFIX}/usr/share/${PN} -maxdepth 1 -type f '!' -name 'bash_completion' -exec emerge -1v {} +"
			ewarn
			ewarn "After the rebuild, you should remove the old setup symlinks:"
			ewarn
			ewarn "$ find ${EPREFIX}/etc/bash_completion.d -type l -delete"
		fi
	done

	if has_version 'app-shells/zsh'; then
		elog
		elog "If you are interested in using the provided bash completion functions with zsh,"
		elog "valuable tips on the effective use of bashcompinit are available:"
		elog "    http://www.zsh.org/mla/workers/2003/msg00046.html"
		elog
	fi
}

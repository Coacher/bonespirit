# Copyright 1999-2015 Gentoo Foundation
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
	app-text/aspell
"
DEPEND="app-arch/xz-utils"
PDEPEND=">=app-shells/gentoo-bashcomp-20140911"

PATCHES=( "${FILESDIR}/${PN}-blacklist-support.patch" )
DOCS=( AUTHORS CHANGES README )

# List unwanted completions to be removed later
STRIP_COMPLETIONS=(
	# Slackware completions
	explodepkg installpkg makepkg pkgtool removepkg sbopkg slackpkg upgradepkg

	# Debian completions
	apt-build apt-cache apt-get aptitude dselect ifup ifdown ifstatus querybts reportbug

	# FreeBSD completions
	freebsd-update kldload kldunload pkg_deinstall pkg_delete pkg_info portinstall portsnap portupgrade

	# Installed in app-editors/vim-core
	xxd

	# Symlinks to deprecated completions
	hd ncal
)

src_prepare() {
	sed -e 's%/profile.d%/bash/bashrc.d%' -i Makefile.am
	autotools-utils_src_prepare
}

src_configure() {
	autotools-utils_src_configure
}

src_install() {
	# Workaround race conditions wrt bug #526996
	mkdir -p "${ED}"/usr/share/bash-completion/{completions,helpers} || die

	autotools-utils_src_install

	# Remove unwanted completions
	local file
	for file in "${STRIP_COMPLETIONS[@]}"; do
		rm "${ED}/usr/share/bash-completion/completions/${file}" || die
	done
	# Remove deprecated completions (moved to other packages)
	rm "${ED}"/usr/share/bash-completion/completions/_* || die

	insinto /usr/share/eselect/modules
	doins "${FILESDIR}/bashcomp.eselect"
	doman "${FILESDIR}/bashcomp.eselect.5"
}

src_test() { :; } # Skip testsuite because of interactive shell wrt bug #477066

pkg_postinst() {
	local v
	for v in ${REPLACING_VERSIONS}; do
		if ! version_is_at_least 2.1-r90 ${v}; then
			ewarn "For bash-completion autoloader to work, all completions need to"
			ewarn "be installed in /usr/share/bash-completion/completions. You may"
			ewarn "need to rebuild packages that installed completions in the old"
			ewarn "location. You can do this using:"
			ewarn
			ewarn "$ find ${EPREFIX}/usr/share/bash-completion -maxdepth 1 -type f '!' -name 'bash_completion' -exec emerge -1v {} +"
			ewarn
			ewarn "After the rebuild, you should remove the old setup symlinks:"
			ewarn
			ewarn "$ find ${EPREFIX}/etc/bash_completion.d -type l -delete"
		fi
	done

	if has_version 'app-shells/zsh'; then
		elog
		elog "If you are interested in using the provided bash completion functions with"
		elog "zsh, valuable tips on the effective use of bashcompinit are available:"
		elog "  http://www.zsh.org/mla/workers/2003/msg00046.html"
		elog
	fi
}

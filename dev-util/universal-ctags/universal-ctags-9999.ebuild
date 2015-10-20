# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
AUTOTOOLS_AUTORECONF=1

inherit autotools-utils git-r3

DESCRIPTION="Generate tag files for source code"
HOMEPAGE="https://ctags.io/"
EGIT_REPO_URI="git://github.com/${PN}/ctags.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+iconv"

DEPEND="
	app-eselect/eselect-ctags
	iconv? ( virtual/libiconv )
"
RDEPEND="${DEPEND}"

src_configure() {
	local myeconfargs=(
		--disable-readlib
		--disable-etags
		$(use_enable iconv)
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	# Prevent file collisions with other ctags implementations
	mv "${D}"/usr/bin/{ctags,universal-ctags} || die
	mv "${D}"/usr/share/man/man1/{ctags,universal-ctags}.1 || die
}

pkg_postinst() {
	eselect ctags update
	elog "You can set the version to be started by /usr/bin/ctags through"
	elog "the ctags eselect module. \"man ctags.eselect\" for details."
}

pkg_postrm() {
	eselect ctags update
}

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=1

inherit autotools-utils latex-package perl-module sgml-catalog toolchain-funcs git-r3

DESCRIPTION="A toolset for processing LinuxDoc DTD SGML files"
HOMEPAGE="https://gitlab.com/agmartin/linuxdoc-tools"
EGIT_REPO_URI="https://gitlab.com/agmartin/${PN}.git"
# Redefine SRC_URI, otherwise latex-package eclass interferes
SRC_URI=""

LICENSE="MIT SGMLUG"
SLOT="0"
KEYWORDS=""
IUSE="doc"

RDEPEND="
	|| ( app-text/openjade app-text/opensp )
	app-text/sgml-common
	dev-lang/perl:=
	|| ( sys-apps/gawk sys-apps/mawk )
	sys-apps/groff
"
DEPEND="${RDEPEND}
	sys-devel/flex
	doc? (
		dev-texlive/texlive-fontsrecommended
		virtual/latex-base
	)
"

DOCS=( ChangeLog README )

sgml-catalog_cat_include "/etc/sgml/linuxdoc.cat" \
	"/usr/share/linuxdoc-tools/linuxdoc-tools.catalog"

src_prepare() {
	# Use Gentoo doc install path.
	sed -i \
		-e "s%/share/doc/linuxdoc-tools%/share/doc/${PF}%" \
		Makefile.in

	autotools-utils_src_prepare
}

src_configure() {
	perl_set_version
	tc-export CC
	local myeconfargs=(
		--disable-docs
		--with-texdir="${TEXMF}/tex/latex/${PN}"
		--with-perllibdir="${VENDOR_ARCH}"
		--with-installed-iso-entities
	)
	use doc && myeconfargs+=(--enable-docs="txt pdf html")

	autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile
}

src_install() {
	# Prevent access violations from bitmap font files generation.
	export VARTEXFONTS="${T}/fonts"

	autotools-utils_src_install
}

pkg_postinst() {
	latex-package_pkg_postinst
	sgml-catalog_pkg_postinst
}

pkg_postrm() {
	latex-package_pkg_postrm
	sgml-catalog_pkg_postrm
}

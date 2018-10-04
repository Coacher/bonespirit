# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit font python-single-r1 subversion

DESCRIPTION="Free UCS outline fonts"
HOMEPAGE="https://www.gnu.org/software/freefont/ https://savannah.gnu.org/projects/freefont/"
ESVN_REPO_URI="svn://svn.savannah.gnu.org/freefont/trunk/freefont"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}
	media-gfx/fontforge[python,${PYTHON_USEDEP}]
"

RESTRICT="binchecks strip"

DOCS="notes/troubleshooting.txt notes/usage.txt"

FONT_SUFFIX="otf"
FONT_S="${S}/sfd"
FONT_CONF=( "${FILESDIR}/69-${PN}.conf" )

src_prepare() {
	default_src_prepare

	# Disable broken fontforge version checks.
	sed -i -e '/TESTFF\|ffversion/d' sfd/Makefile || die
}

src_compile() {
	emake FF="${EPREFIX}/usr/bin/fontforge" "${FONT_SUFFIX}"
}

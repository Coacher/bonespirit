# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4} )

inherit font python-single-r1 subversion

DESCRIPTION="Unicode fonts from the Free UCS Outline Fonts Project"
HOMEPAGE="http://savannah.nongnu.org/projects/freefont/"
ESVN_REPO_URI="svn://svn.savannah.gnu.org/${PN}/trunk/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="$(python_gen_any_dep 'media-gfx/fontforge[python,${PYTHON_USEDEP}]')"

DOCS="notes/troubleshooting.txt"

FONT_SUFFIX="otf"
FONT_S="${S}/sfd"
FONT_CONF=( "${FILESDIR}/69-${PN}.conf" )

python_check_deps() {
	has_version "media-gfx/fontforge[python,${PYTHON_USEDEP}]"
}

src_prepare() {
	sed -i -e '/TESTFF\|ffversion/d' sfd/Makefile || die
	default
}

src_compile() {
	emake "${FONT_SUFFIX}" || die
}

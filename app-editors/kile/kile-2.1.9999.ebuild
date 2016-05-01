# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit kde4-base git-r3

DESCRIPTION="A Latex Editor and TeX shell for KDE"
HOMEPAGE="http://kile.sourceforge.net/"
EGIT_REPO_URI="git://anongit.kde.org/${PN}.git"
EGIT_BRANCH="2.1"

LICENSE="FDL-1.2 GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE="debug +pdf +png"

DEPEND="
	x11-misc/shared-mime-info
"
RDEPEND="${DEPEND}
	$(add_kdeapps_dep kdebase-data)
	|| ( $(add_kdeapps_dep konsolepart) $(add_kdeapps_dep konsole) )
	|| (
		$(add_kdeapps_dep okular 'pdf?,postscript')
		app-text/acroread
	)
	virtual/latex-base
	virtual/tex-base
	pdf? (
		|| (
			app-text/dvipdfmx
			>=app-text/texlive-core-2014
		)
		app-text/ghostscript-gpl
	)
	png? (
		app-text/dvipng
		media-gfx/imagemagick[png]
	)
"

DOCS=( kile-remote-control.txt )

src_prepare() {
	kde4-base_src_prepare

	sed -i \
		-e '/INSTALL( FILES AUTHORS/s/^/#DISABLED /' \
		CMakeLists.txt || die
}

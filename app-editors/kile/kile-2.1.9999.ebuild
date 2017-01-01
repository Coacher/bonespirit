# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit kde4-base

DESCRIPTION="A user-friendly TeX/LaTeX editor for KDE"
HOMEPAGE="http://kile.sourceforge.net/ https://www.kde.org/applications/office/kile/"
EGIT_BRANCH="2.1"

LICENSE="GPL-2+"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE="debug +pdf +png"

DEPEND="x11-misc/shared-mime-info"
RDEPEND="${DEPEND}
	|| ( $(add_kdeapps_dep okular 'pdf?,postscript') app-text/acroread )
	$(add_kdeapps_dep kdebase-data)
	$(add_kdeapps_dep konsolepart)
	virtual/latex-base
	virtual/tex-base
	pdf? (
		app-text/ghostscript-gpl
		|| ( app-text/dvipdfmx >=app-text/texlive-core-2014 )
	)
	png? (
		app-text/dvipng
		media-gfx/imagemagick[png]
	)
"

src_prepare() {
	kde4-base_src_prepare

	# Disable unconditional documentation installation to the wrong directory.
	sed -i -e '/README/d' CMakeLists.txt || die

	# Disable unconditional docbook documentation build.
	sed -i -e '/ADD_SUBDIRECTORY( doc )/d' CMakeLists.txt || die
	rm -r doc/ || die
}

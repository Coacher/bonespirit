# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

KDE_DOC_DIRS="doc"
KDE_HANDBOOK="optional"
inherit kde4-base git-r3

EGIT_REPO_URI="git://anongit.kde.org/${PN}.git"
# last commit to master before frameworks branch was merged
EGIT_COMMIT="653a1b8e3886e0d68fbbea40ba298c44e00f0848"

DESCRIPTION="A Latex Editor and TeX shell for KDE"
HOMEPAGE="http://kile.sourceforge.net/"

LICENSE="FDL-1.2 GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE="debug +pdf +png"

DEPEND="
	x11-misc/shared-mime-info
"
RDEPEND="${DEPEND}
	$(add_kdeapps_dep kdebase-data)
	$(add_kdeapps_dep konsole)
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

	# I know upstream wants to help us, but it doesn't work.
	sed -e '/INSTALL( FILES AUTHORS/s/^/#DISABLED /' \
		-i CMakeLists.txt || die

	if ! use handbook; then
		rm -r doc/ || die
	fi
}

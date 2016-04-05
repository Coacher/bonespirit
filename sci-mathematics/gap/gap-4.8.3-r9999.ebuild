# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools elisp-common versionator

DESCRIPTION="System for computational discrete algebra"
HOMEPAGE="http://www.gap-system.org/"
SRC_URI="https://github.com/gap-system/gap/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="emacs readline vim-syntax"

RESTRICT="mirror"

DEPEND="
	dev-libs/gmp:=
	readline? ( sys-libs/readline:= )
"
RDEPEND="${DEPEND}
	emacs? ( virtual/emacs )
	vim-syntax? ( app-vim/vim-gap )
"
PDEPEND="dev-gap/GAPDoc"

PATCHES=(
	"${FILESDIR}"/${PN}-4.5.7-writeandcheck.patch
	"${FILESDIR}"/${PN}-4.8.3-configdir.patch
)

update_version_info() {
	local RELEASE_DATE='19-Mar-2016' # XXX: update this every release.
	local RELEASE_YEAR=${RELEASE_DATE##*-}

	# See DistributionUpdate/updateversioninfo script from
	# https://github.com/gap-system/gap-distribution repo.
	sed -i -e "s|4\.dev|${PV}|g" \
		CITATION \
		lib/system.g \
		src/system.c \
		doc/versiondata \
		cnf/configure.in \
		cnf/configure.out \
		|| die

	sed -i -e "s|today|${RELEASE_DATE}|g" \
		lib/system.g \
		doc/versiondata \
		|| die

	sed -i -e "s|this year|${RELEASE_YEAR}|g" \
		CITATION \
		doc/versiondata \
		|| die

	sed -i -e "s|gap4dev|gap4r$(get_version_component_range 2)|g" \
		src/system.c \
		doc/versiondata \
		|| die

	sed -i \
		-e "s|unknown|\"${PV}, ${RELEASE_DATE}, build\"|g" \
		cnf/mkversionheader.sh || die
}

src_prepare() {
	default

	update_version_info

	eautoreconf

	pushd cnf > /dev/null || die
		eautoreconf
		# This is the way upstream rolls, see cnf/Makefile.
		mv configure configure.out || die
	popd > /dev/null || die

	# Removing dev stuff in doc.
	pushd doc > /dev/null || die
		rm -r -- dev/ *.{bib,tex} manualindex README* || die
	popd > /dev/null || die
}

src_configure() {
	econf \
		--with-gmp=system \
		$(use_with readline) \
		ABI=

	emake config ABI=
}

src_compile() {
	default

	source sysinfo.gap
	pushd "bin/${GAParch_system}" > /dev/null || die
		# Replace the objects needed by gac with an archive.
		# compstat.o is omitted on purpose from this list, see cnf/gac.in.
		rm compstat.o || die
		ar qv libgap.a *.o || die "failed to produce the libgap archive"
	popd > /dev/null || die
}

src_install() {
	insinto /usr/include/${P}
	doins src/*.h

	insinto /usr/$(get_libdir)/${PN}
	# This is excruciatingly slow even with the reduced content.
	# An install target in the makefile may speed things up.
	doins -r \
		doc \
		grp \
		lib \
		prim \
		small \
		trans \
		sysinfo.gap*

	dosym /usr/$(get_libdir)/${PN}/sysinfo.gap /etc/sysinfo.gap

	source sysinfo.gap

	exeinto "/usr/$(get_libdir)/${PN}/bin/${GAParch_system}"
	doexe "bin/${GAParch_system}"/{gap,libgap.a}

	exeinto /usr/$(get_libdir)/${PN}/bin
	doexe bin/gap*.sh

	newbin "bin/${GAParch_system}/gac" gac
	newbin bin/gap.sh gap
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}

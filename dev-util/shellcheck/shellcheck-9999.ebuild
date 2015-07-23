# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

CABAL_FEATURES="bin lib profile haddock hoogle hscolour test-suite"

inherit haskell-cabal git-r3

EGIT_REPO_URI="git://github.com/koalaman/${PN}.git"

DESCRIPTION="Shell script analysis tool"
HOMEPAGE="http://www.shellcheck.net/"

LICENSE="GPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="
	dev-haskell/json:=[profile?]
	dev-haskell/mtl:=[profile?]
	dev-haskell/parsec:=[profile?]
	>=dev-haskell/quickcheck-2.7.4:2=[profile?]
	dev-haskell/regex-tdfa:=[profile?]
	dev-haskell/transformers:=[profile?]
	>=dev-lang/ghc-7.8.4:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	doc? ( app-text/pandoc )
	test? ( >=dev-haskell/cabal-1.20 )
"

src_test() {
	# See bug #537500 for this beauty.
	runghc Setup.hs test || die 'test suite failed'
}

src_install() {
	cabal_src_install
	if use doc; then
		pandoc -s -t man "${PN}.1.md" -o "${PN}.1" || die
		doman "${PN}.1"
	fi
}

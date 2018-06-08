# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"

inherit haskell-cabal git-r3

DESCRIPTION="Shell script analysis tool"
HOMEPAGE="https://www.shellcheck.net/ https://github.com/koalaman/shellcheck"
EGIT_REPO_URI="https://github.com/koalaman/shellcheck.git"

LICENSE="GPL-3+"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="
	dev-haskell/aeson:=[profile?]
	>=dev-haskell/mtl-2.2.1:=[profile?]
	>=dev-haskell/parsec-3.0:=[profile?]
	>=dev-haskell/quickcheck-2.7.4:2=[profile?]
	dev-haskell/regex-tdfa:=[profile?]
	>=dev-lang/ghc-8:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.10
	doc? ( app-text/pandoc )
	test? ( >=dev-haskell/cabal-1.20 )
"

src_install() {
	cabal_src_install
	if use doc; then
		pandoc -s -t man ${PN}.1.md -o ${PN}.1 || die
		doman ${PN}.1
	fi
}

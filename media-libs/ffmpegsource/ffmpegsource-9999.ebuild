# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils git-r3

DESCRIPTION="A libav/ffmpeg based source library for easy frame accurate access"
HOMEPAGE="https://github.com/FFMS/ffms2"
EGIT_REPO_URI=( {https,git}://github.com/FFMS/ffms2.git )

LICENSE="MIT"
SLOT="0/4"
KEYWORDS=""
IUSE="libav"

RDEPEND="
	sys-libs/zlib
	!libav? ( >=media-video/ffmpeg-2.4:0= )
	libav? ( >=media-video/libav-9:0= )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	default_src_prepare
	eautoreconf
}

src_install() {
	default_src_install
	prune_libtool_files
}

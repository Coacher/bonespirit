# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="An encoding detector library"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/uchardet/"
EGIT_REPO_URI="https://anongit.freedesktop.org/git/uchardet/uchardet.git"

LICENSE="|| ( MPL-1.1 GPL-2+ LGPL-2.1+ )"
SLOT="0"
KEYWORDS=""
IUSE="cpu_flags_x86_sse2 static-libs test"

src_prepare() {
	# Override halfway broken uname-based architecture detection
	sed -i -e '/CMAKE_SYSTEM_PROCESSOR/d' CMakeLists.txt || die

	cmake-utils_src_prepare
	use test || cmake_comment_add_subdirectory test
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_STATIC=$(usex static-libs)
		-DCHECK_SSE2=$(usex cpu_flags_x86_sse2)
		-DTARGET_ARCHITECTURE=${ARCH}
	)
	cmake-utils_src_configure
}

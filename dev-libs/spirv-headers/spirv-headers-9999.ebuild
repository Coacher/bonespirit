# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="SPIR-V headers from Khronos Group"
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Headers"
EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Headers.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

src_prepare() {
	cmake-utils_src_prepare
	cmake_comment_add_subdirectory example
}

src_install() {
	insinto /usr/include/spirv
	doins -r "${S}"/include/spirv/*
	einstalldocs
}

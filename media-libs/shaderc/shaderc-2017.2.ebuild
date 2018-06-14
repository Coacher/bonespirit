# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

COMMIT_ID="7a23a01742b88329fb2260eda007172135ba25d4"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit cmake-multilib python-any-r1 vcs-snapshot

DESCRIPTION="Collection of tools, libraries and tests for shader compilation"
HOMEPAGE="https://github.com/google/shaderc"
SRC_URI="https://github.com/google/shaderc/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples test"

RDEPEND="
	dev-util/glslang[${MULTILIB_USEDEP}]
	dev-util/spirv-tools[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-util/spirv-headers
	doc? ( dev-ruby/asciidoctor )
	test? (
		dev-cpp/gtest
		dev-python/nose
	)
"

# https://github.com/google/shaderc/issues/470
RESTRICT=test

PATCHES=(
	"${FILESDIR}/${P}-disable-git-versioning.patch"
	"${FILESDIR}/${P}-fix-glslang-link-order.patch"
)

src_prepare() {
	# This must go first as git-ver patch clashes with commenting out examples
	cmake-utils_src_prepare
	use examples || cmake_comment_add_subdirectory examples

	# Unbundle glslang, spirv-headers, spirv-tools
	cmake_comment_add_subdirectory third_party
	sed -i \
		-e "s|\$<TARGET_FILE:spirv-dis>|${EPREFIX}/usr/bin/spirv-dis|" \
		glslc/test/CMakeLists.txt || die

	# Manually create build-version.inc as we disabled git versioning
	cat <<- EOF > glslc/src/build-version.inc || die
		"${P}\n"
		"$(best_version dev-util/spirv-tools)\n"
		"$(best_version dev-util/glslang)\n"
	EOF
}

multilib_src_configure() {
	local mycmakeargs=(
		-DSHADERC_SKIP_TESTS="$(usex !test)"
	)
	cmake-utils_src_configure
}

multilib_src_compile() {
	if multilib_is_native_abi && use doc; then
		emake glslc_doc_README
	fi

	cmake-utils_src_compile
}

multilib_src_install() {
	if multilib_is_native_abi && use doc; then
		local HTML_DOCS=( "${BUILD_DIR}/glslc/README.html" )
	fi
	use examples && dobin examples/online-compile/shaderc-online-compile

	cmake-utils_src_install
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )
PYTHON_REQ_USE='threads(+),xml(+)'
DISTUTILS_SINGLE_IMPL=1 # https://github.com/git-cola/git-cola/issues/181
PLOCALES="de es fr hu id_ID it ja pl pt_BR ru sv tr_TR zh_CN zh_TW"

inherit distutils-r1 eutils gnome2-utils l10n readme.gentoo-r1 xdg-utils git-r3

DESCRIPTION="The highly caffeinated Git GUI"
HOMEPAGE="https://git-cola.github.io/"
EGIT_REPO_URI=( {https,git}://github.com/${PN}/${PN}.git )

LICENSE="GPL-2 doc? ( BSD )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

# git-cola bundles sphinxtogithub. See Gentoo bug 588568.
RDEPEND="
	dev-python/QtPy[gui,webkit,${PYTHON_USEDEP}]
	dev-python/send2trash[${PYTHON_USEDEP}]
	dev-vcs/git
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	doc? (
		dev-python/sphinx[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/sphinxtogithub[${PYTHON_USEDEP}]' python2_7)
	)
	test? (
		dev-python/nose[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/mock[${PYTHON_USEDEP}]' python2_7)
	)
"

src_prepare() {
	remove_locale() {
		rm "po/${1}.po" || die
		# Not all locales have these.
		rm -f "po/glossary/${1,,}"
		rm -f "share/doc/${PN}/hotkeys_${1}.html"
	}

	l10n_find_plocales_changes 'po' '' '.po'
	l10n_for_each_disabled_locale_do remove_locale

	# Avoid installing broken symlink to 'relnotes.rst'.
	rm CHANGELOG || die

	distutils-r1_src_prepare
}

python_prepare_all() {
	# Remove bundled ssh-askpass scripts.
	rm share/${PN}/bin/ssh-askpass* || die

	# Look for ssh-askpass under /usr.
	sed -i -e '/askpass =/s/\.share/.prefix/g' cola/app.py || die

	# Disable unconditional documentation installation to the wrong directory.
	sed -i -e "\|share/doc/${PN}|d" setup.py || die

	# Look for documentation in Gentoo paths.
	sed -i -e "s|'doc', '${PN}'|'doc', '${PF}'|g" cola/resources.py || die

	# Remove broken tests.
	rm test/i18n_test.py || die

	distutils-r1_python_prepare_all
}

python_configure_all() {
	mydistutilsargs=( --no-vendor-libs )
}

python_compile_all() {
	use doc && emake -C share/doc/${PN} all
}

python_test() {
	distutils_install_for_testing
	emake test
}

python_install() {
	# Remove this when git-cola supports multiple Python implementations.
	distutils-r1_python_install
	python_fix_shebang "${ED}"usr/share/${PN}/bin/git-xbase
	python_optimize "${ED}"usr/share/${PN}/lib/
}

src_install() {
	use doc || HTML_DOCS=( "${FILESDIR}/index.html" )

	distutils-r1_src_install
	readme.gentoo_create_doc

	doicon -s scalable share/${PN}/icons/${PN}.svg

	local myemaketargets=( install-files )
	use doc && myemaketargets+=( install-html install-man )

	emake -C share/doc/${PN} \
		DESTDIR="${D}" \
		prefix="${EPREFIX}/usr" \
		docdir="${EPREFIX}/usr/share/doc/${PF}" \
		"${myemaketargets[@]}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	readme.gentoo_print_elog

	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

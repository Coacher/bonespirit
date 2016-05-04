# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
DISTUTILS_SINGLE_IMPL=1
PLOCALES="de es fr hu id_ID it ja pt_BR ru sv tr_TR zh_CN zh_TW"

inherit distutils-r1 eutils fdo-mime gnome2-utils l10n readme.gentoo-r1 git-r3

DESCRIPTION="The highly caffeinated Git GUI"
HOMEPAGE="https://git-cola.github.io/"
EGIT_REPO_URI="git://github.com/${PN}/${PN}.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="
	dev-python/PyQt4[${PYTHON_USEDEP}]
	dev-python/send2trash[${PYTHON_USEDEP}]
	dev-vcs/git
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	doc? (
		dev-python/sphinx[${PYTHON_USEDEP}]
		python_targets_python2_7? (
			dev-python/sphinxtogithub[$(python_gen_usedep 'python2*')]
		)
	)
	test? (
		dev-python/nose[${PYTHON_USEDEP}]
		python_targets_python2_7? (
			dev-python/mock[$(python_gen_usedep 'python2*')]
		)
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

	distutils-r1_src_prepare
}

python_prepare_all() {
	# Remove bundled ssh-askpass scripts.
	rm share/${PN}/bin/ssh-askpass* || die

	# Use proper directory to search for ssh-askpass.
	sed -i -e '/askpass =/s/\.share/.prefix/g' cola/app.py || die

	# Disable unconditional documentation installation to the wrong directory.
	sed -i -e "/doc\/${PN}/d" setup.py || die

	# Use proper directory to search for documentation.
	sed -i -e "s/'doc', '${PN}'/'doc', '${PF}'/g" cola/resources.py || die

	# Remove broken tests.
	rm test/i18n_test.py || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C share/doc/${PN} all
}

python_test() {
	distutils_install_for_testing
	emake test
}

python_install_all() {
	local myemaketargets=( install-files )
	use doc && myemaketargets+=(install-html install-man)

	emake \
		-C share/doc/${PN} \
		DESTDIR="${D}" \
		prefix="${EPREFIX}/usr" \
		docdir="${EPREFIX}/usr/share/doc/${PF}" \
		"${myemaketargets[@]}"

	doicon -s scalable share/${PN}/icons/${PN}.svg

	use doc || HTML_DOCS=( "${FILESDIR}/index.html" )

	python_fix_shebang "${ED}"usr/share/${PN}/bin/git-xbase
	python_optimize "${ED}"usr/share/${PN}/lib/cola

	distutils-r1_python_install_all
	readme.gentoo_create_doc
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	readme.gentoo_print_elog
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

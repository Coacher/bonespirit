# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4} )
DISTUTILS_SINGLE_IMPL=1

PLOCALES="de es fr hu id_ID it ja pt_BR ru sv tr_TR zh_CN zh_TW"

inherit distutils-r1 l10n readme.gentoo-r1 git-r3

DESCRIPTION="The highly caffeinated git GUI"
HOMEPAGE="https://git-cola.github.io/"
EGIT_REPO_URI="git://github.com/${PN}/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc test"

RDEPEND="
	dev-python/PyQt4[${PYTHON_USEDEP}]
	dev-python/pyinotify[${PYTHON_USEDEP}]
	dev-python/send2trash[${PYTHON_USEDEP}]
	dev-vcs/git
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	doc? (
		dev-python/sphinx[${PYTHON_USEDEP}]
		python_targets_python2_7? ( dev-python/sphinxtogithub[$(python_gen_usedep 'python2*')] )
	)
	test? ( dev-python/nose[${PYTHON_USEDEP}] )
"

src_prepare() {
	remove_locale() {
		rm "po/${1}.po" || die
		rm -f "po/glossary/${1,,}"					# Not all locales have this
		rm -f "share/doc/${PN}/hotkeys_${1}.html"	# Not all locales have this
	}

	l10n_find_plocales_changes 'po' '' '.po'
	l10n_for_each_disabled_locale_do remove_locale

	distutils-r1_src_prepare
}

python_prepare_all() {
	# Remove bundled ssh-askpass
	rm share/${PN}/bin/ssh-askpass* || die

	# Remove broken tests
	rm test/i18n_test.py || die

	# Don't install docs into wrong location
	sed -i -e "/share\/doc\/${PN}/d" setup.py || die

	# Fix doc directory reference
	sed -i \
		-e "s/'share', 'doc', '${PN}'/'share', 'doc', '${PF}'/" \
		cola/resources.py || die

	# Fix ssh-askpass directory reference
	sed -i -e 's/resources\.share/resources\.prefix/' cola/app.py || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	cd share/doc/${PN}/ || die
	if use doc; then
		emake all
	else
		sed -i \
			-e '/^install:/s%install-html%%' \
			-e '/^install:/s%install-man%%' \
			Makefile || die
	fi
}

python_test() {
	PYTHONPATH="${S}:${S}/build/lib:${PYTHONPATH}" \
	LC_ALL="C" \
	emake test
}

python_install_all() {
	cd share/doc/${PN}/ || die
	emake \
		DESTDIR="${D}" \
		docdir="${EPREFIX}/usr/share/doc/${PF}" \
		prefix="${EPREFIX}/usr" \
		install

	python_fix_shebang "${ED}/usr/share/${PN}/bin/git-xbase"
	python_optimize "${ED}/usr/share/${PN}/lib/cola"

	use doc || HTML_DOCS=( "${FILESDIR}"/index.html )

	distutils-r1_python_install_all
	readme.gentoo_create_doc
}

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
USE_RUBY="ruby19"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="CHANGES README doc/io_extra.txt"
RUBY_FAKEGEM_RECIPE_TEST="none"

inherit multilib ruby-fakegem

DESCRIPTION="Additional methods for the IO class on Unix platforms"
HOMEPAGE="https://github.com/djberg96/io-extra"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

ruby_add_bdepend "test? ( >=dev-ruby/test-unit-2.5.1-r1 )"

each_ruby_configure() {
	${RUBY} -C ext extconf.rb || die
}

each_ruby_compile() {
	emake -C ext
	mkdir -p lib/io || die
	cp ext/extra$(get_modname) lib/io/ || die
}

each_ruby_test() {
	ruby-ng_testrb-2 -Ilib test/* || die
}

all_ruby_install() {
	all_fakegem_install

	if use examples; then
		docinto examples
		dodoc examples/*
	fi
}

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
USE_RUBY="ruby19"

RUBY_FAKEGEM_RECIPE_DOC="rdoc"
RUBY_FAKEGEM_DOC_SOURCES="lib ext/${PN}/*.c"
RUBY_FAKEGEM_EXTRADOC="NEWS README"
RUBY_FAKEGEM_RECIPE_TEST="none"

inherit multilib ruby-fakegem

DESCRIPTION="Non-blocking IO methods for Ruby without raising exceptions on
EAGAIN and EINPROGRESS"
HOMEPAGE="http://bogomips.org/kgio/"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

ruby_add_bdepend "test? ( =dev-ruby/test-unit-3* )"

each_ruby_configure() {
	${RUBY} -C ext/${PN} extconf.rb || die
}

each_ruby_compile() {
	emake -C ext/${PN}
	cp ext/${PN}/${PN}_ext$(get_modname) lib/ || die
}

each_ruby_test() {
	ruby-ng_testrb-2 -Ilib test/* || die
}

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

DESCRIPTION="Real-time stats toolkit to show statistics for Rack HTTP servers"
HOMEPAGE="http://raindrops.bogomips.org/"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

ruby_add_bdepend "
	test? (
		=dev-ruby/test-unit-3*
		>=dev-ruby/ruby-aggregate-0.2
		=dev-ruby/ruby-aggregate-0*
		>=dev-ruby/io-extra-1.2.3
		=dev-ruby/io-extra-1*
		=dev-ruby/posix_mq-2*
		=dev-ruby/rack-1*
		dev-ruby/unicorn
	)
"

each_ruby_configure() {
	${RUBY} -C ext/${PN} extconf.rb || die
}

each_ruby_compile() {
	emake -C ext/${PN}
	cp ext/${PN}/${PN}_ext$(get_modname) lib/ || die
}

each_ruby_test() {
	emake test
}

all_ruby_install() {
	all_fakegem_install

	if use examples; then
		docinto examples
		dodoc examples/*
	fi
}

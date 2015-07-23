# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_RUBY="ruby19"

RUBY_FAKEGEM_RECIPE_DOC="rdoc"
RUBY_FAKEGEM_EXTRADOC="FAQ KNOWN_ISSUES NEWS README SIGNALS TUNING"
RUBY_FAKEGEM_RECIPE_TEST="none"

inherit multilib ruby-fakegem

DESCRIPTION="HTTP server for Rack applications designed to only serve fast
clients"
HOMEPAGE="http://unicorn.bogomips.org/"

LICENSE="|| ( GPL-2+ Ruby )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

ruby_add_rdepend "
	dev-ruby/rack:*
	>=dev-ruby/kgio-2.6
	=dev-ruby/kgio-2*
	>=dev-ruby/raindrops-0.7
	=dev-ruby/raindrops-0*
"

ruby_add_bdepend "test? ( =dev-ruby/test-unit-3* )"

each_ruby_configure() {
	${RUBY} -C ext/${PN}_http extconf.rb || die
}

each_ruby_compile() {
	emake -C ext/${PN}_http
	cp ext/${PN}_http/${PN}_http$(get_modname) lib/ || die
}

each_ruby_test() {
	emake test
}

all_ruby_install() {
	all_fakegem_install

	if use examples; then
		rm examples/init.sh || die
		docinto examples
		dodoc examples/*
	fi

	doman man/man1/${PN}.1
	doman man/man1/${PN}_rails.1

	newinitd "${FILESDIR}/${PN}.init" ${PN}
	newconfd "${FILESDIR}/${PN}.confd" ${PN}

	insinto /etc/logrotate.d/
	newins "${FILESDIR}/${PN}.logrotate" ${PN}
}

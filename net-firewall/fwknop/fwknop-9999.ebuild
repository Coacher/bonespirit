# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# Does work with python2_7, does not work with python3_3 on my machine
# More feedback is welcome, since setup.py does not provide any info
PYTHON_COMPAT=( python2_7 )
DISTUTILS_OPTIONAL=1
DISTUTILS_SINGLE_IMPL=1
AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=0

inherit autotools-utils distutils-r1 systemd git-r3

DESCRIPTION="Single Packet Authorization and Port Knocking application"
HOMEPAGE="http://www.cipherdyne.org/fwknop/"
EGIT_REPO_URI="git://github.com/mrash/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="client extras firewalld gdbm gpg python server udp-server"

RDEPEND="
	client? ( net-misc/wget[ssl] )
	gpg? (
		dev-libs/libassuan
		dev-libs/libgpg-error
	)
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}
	gdbm? ( sys-libs/gdbm )
	gpg? ( app-crypt/gpgme )
	server? (
		firewalld? ( net-firewall/firewalld )
		!firewalld? ( net-firewall/iptables )
		!udp-server? ( net-libs/libpcap )
	)
"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	firewalld? ( server )
	udp-server? ( server )
"

DOCS=( ChangeLog README.md )

src_prepare() {
	# Install example configs with .example suffix
	if use server; then
		sed -i 's/conf;/conf.example;/g' "${S}"/Makefile.am || die
	fi

	autotools-utils_src_prepare

	if use python; then
		cd "${S}"/python || die
		distutils-r1_src_prepare
	fi
}

src_configure() {
	local myeconfargs=(
		--localstatedir=/run
		--enable-digest-cache
		$(use_enable client)
		$(use_enable !gdbm file-cache)
		$(use_enable server)
		$(use_enable udp-server)
		$(use_with gpg gpgme)
	)
	if use server; then
		if ! use firewalld; then
			myeconfargs+=(--with-iptables=/sbin/iptables)
		else
			myeconfargs+=(--with-firewalld=/usr/sbin/firewalld)
		fi
	fi
	autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile

	if use python; then
		cd "${S}"/python || die
		distutils-r1_src_compile
	fi
}

src_install() {
	autotools-utils_src_install
	prune_libtool_files --modules

	if use server; then
		newinitd "${FILESDIR}/fwknopd.init" fwknopd
		newconfd "${FILESDIR}/fwknopd.confd" fwknopd
		systemd_dounit "${FILESDIR}/fwknopd.service"
		systemd_newtmpfilesd "${FILESDIR}/fwknopd.tmpfiles.conf" fwknopd.conf
	fi

	use extras && dodoc "${S}/extras/apparmor/usr.sbin.fwknopd"

	if use python; then
		# Unset DOCS since distutils-r1.eclass interferes
		local DOCS=()
		cd "${S}"/python || die
		distutils-r1_src_install
	fi
}

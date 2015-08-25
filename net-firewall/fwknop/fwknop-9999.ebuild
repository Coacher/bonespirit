# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# Does work with python2_7, does not work with python3_3 on my machine
# More feedback is welcome, since setup.py does not provide any info
PYTHON_COMPAT=( python2_7 )
DISTUTILS_OPTIONAL=1
DISTUTILS_SINGLE_IMPL=1
AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=0

inherit autotools-utils distutils-r1 linux-info readme.gentoo systemd git-r3

DESCRIPTION="Single Packet Authorization and Port Knocking application"
HOMEPAGE="http://www.cipherdyne.org/fwknop/"
EGIT_REPO_URI="git://github.com/mrash/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="client extras firewalld gdbm gpg iptables python server udp-server"

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
	firewalld? ( net-firewall/firewalld )
	iptables? ( net-firewall/iptables )
	server? ( !udp-server? ( net-libs/libpcap ) )
"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	firewalld? ( server )
	iptables? ( server )
	server? ( ^^ ( firewalld iptables ) )
	udp-server? ( server )
"

DOCS=( ChangeLog README.md )
DOC_CONTENTS="
	fwknopd supports several backends: firewalld, iptables, ipfw, pf, ipf.
	You can set the desired backend via FIREWALL_EXE option in fwknopd.conf
	instead of the default one chosen at compile time.
"

pkg_pretend() {
	if use server; then
		if ! linux_config_exists || ! linux_chkconfig_present NETFILTER_XT_MATCH_COMMENT; then
			ewarn "fwknopd uses the iptables 'comment' match to expire SPA rules,"
			ewarn "which is a major security feature and is enabled by default."
			ewarn "Please either enable NETFILTER_XT_MATCH_COMMENT support in your"
			ewarn "kernel, or set the appropriate ENABLE_{FIREWD,IPT}_COMMENT_OPTION"
			ewarn "to 'N' in your fwknopd.conf file."
		fi
	fi
}

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
	use firewalld && myeconfargs+=(--with-firewalld=/usr/sbin/firewalld)
	use iptables && myeconfargs+=(--with-iptables=/sbin/iptables)

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
		systemd_dounit extras/systemd/fwknopd.service
		systemd_newtmpfilesd extras/systemd/fwknopd.tmpfiles.conf fwknopd.conf
		readme.gentoo_create_doc
	fi

	use extras && dodoc "${S}/extras/apparmor/usr.sbin.fwknopd"

	if use python; then
		# Unset DOCS since distutils-r1.eclass interferes
		local DOCS=()
		cd "${S}"/python || die
		distutils-r1_src_install
	fi
}

pkg_postinst() {
	use server && readme.gentoo_print_elog
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools systemd git-r3

DESCRIPTION="Daemon for managing internet connections"
HOMEPAGE="https://01.org/connman"
EGIT_REPO_URI="https://git.kernel.org/pub/scm/network/${PN}/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bluetooth debug doc +ethernet examples l2tp ofono openconnect openvpn policykit pptp tools vpnc +wifi wispr"

RDEPEND="
	>=dev-libs/glib-2.28
	>=sys-apps/dbus-1.4
	>=net-firewall/iptables-1.4.8
	bluetooth? ( net-wireless/bluez )
	l2tp? ( net-dialup/xl2tpd )
	ofono? ( net-misc/ofono )
	openconnect? ( net-misc/openconnect )
	openvpn? ( net-misc/openvpn )
	policykit? ( sys-auth/polkit )
	pptp? ( net-dialup/pptpclient )
	vpnc? ( net-misc/vpnc )
	wifi? ( >=net-wireless/wpa_supplicant-2.0[dbus] )
	wispr? ( net-libs/gnutls )
"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-2.6.39
	virtual/pkgconfig
"

src_prepare() {
	default_src_prepare

	# Fix polkit detection.
	sed -i -e '/actiondir/s/polkit/polkit-gobject-1/' configure.ac || die

	eautoreconf
}

src_configure() {
	econf \
		--localstatedir=/var \
		--enable-client \
		--enable-datafiles \
		--enable-loopback=builtin \
		--disable-hh2serial-gps \
		--disable-iospm \
		--disable-tist \
		$(use_enable debug) \
		$(use_enable openconnect openconnect builtin) \
		$(use_enable openvpn openvpn builtin) \
		$(use_enable vpnc vpnc builtin) \
		$(use_enable l2tp l2tp builtin) \
		$(use_enable pptp pptp builtin) \
		$(use_enable examples test) \
		$(use_enable policykit polkit builtin) \
		$(use_enable ethernet ethernet builtin) \
		$(use_enable wifi wifi builtin) \
		$(use_enable bluetooth bluetooth builtin) \
		$(use_enable ofono ofono builtin) \
		$(use_enable wispr wispr builtin) \
		$(use_enable tools)
}

src_install() {
	default_src_install
	dobin client/connmanctl
	use doci && dodoc doc/*.txt

	keepdir /var/lib/${PN}
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
}

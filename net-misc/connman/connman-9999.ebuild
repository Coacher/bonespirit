# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools systemd git-r3

DESCRIPTION="Daemon for managing internet connections"
HOMEPAGE="https://01.org/connman"
EGIT_REPO_URI="https://git.kernel.org/pub/scm/network/connman/connman.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bluetooth debug doc dundee +ethernet examples l2tp networkmanager nfc
	ofono openconnect openvpn policykit pptp selinux tools usb vpnc +wifi
	wispr"

RDEPEND="
	dev-libs/glib:2
	net-firewall/iptables
	sys-apps/dbus
	bluetooth? ( net-wireless/bluez )
	dundee? ( net-misc/ofono[dundee] )
	l2tp? ( net-dialup/xl2tpd )
	nfc? ( net-wireless/neard )
	ofono? ( net-misc/ofono )
	openconnect? ( net-vpn/openconnect )
	openvpn? ( net-vpn/openvpn )
	policykit? ( sys-auth/polkit )
	pptp? ( net-dialup/pptpclient )
	vpnc? ( net-vpn/vpnc )
	wifi? ( >=net-wireless/wpa_supplicant-2.0[dbus] )
	wispr? ( net-libs/gnutls:= )
"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-2.6.39
	virtual/pkgconfig
"

src_prepare() {
	default_src_prepare

	# Fix polkit detection. See Gentoo bug 596276.
	sed -i -e '/actiondir/s/polkit/polkit-gobject-1/' configure.ac || die

	# Don't overwrite existing '/etc/resolv.conf' file.
	sed -i -e '/resolv\.conf/s/^L+/L/' scripts/connman_resolvconf.conf.in || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--localstatedir="${EPREFIX}/var"
		--with-systemdunitdir=$(systemd_get_systemunitdir)
		--with-tmpfilesdir="${EPREFIX}/usr/lib/tmpfiles.d"
		--disable-hh2serial-gps	# Requires specific hardware.
		--disable-iospm			# Requires specific hardware.
		--disable-tist			# Requires specific hardware.
		--enable-session-policy-local=builtin
		--enable-loopback
		--disable-pacrunner		# Only available in overlays.
		--enable-client
		--enable-datafiles
		$(use_enable debug)
		$(use_enable openconnect openconnect builtin)
		$(use_enable openvpn openvpn builtin)
		$(use_enable vpnc vpnc builtin)
		$(use_enable l2tp l2tp builtin)
		$(use_enable pptp pptp builtin)
		$(use_enable examples test)
		$(use_enable networkmanager nmcompat)
		$(use_enable policykit polkit)
		$(use_enable selinux)
		$(use_enable ethernet)
		$(use_enable usb gadget)
		$(use_enable wifi)
		$(use_enable bluetooth)
		$(use_enable ofono)
		$(use_enable dundee)
		$(use_enable nfc neard)
		$(use_enable wispr)
		$(use_enable tools)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default_src_install
	dobin client/connmanctl
	use doc && dodoc doc/*.txt

	keepdir /var/lib/${PN}
	keepdir /usr/$(get_libdir)/${PN}/scripts
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
}

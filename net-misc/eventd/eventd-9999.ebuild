# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools linux-info systemd git-r3

DESCRIPTION="A small daemon to act on remote or local events"
HOMEPAGE="https://www.eventd.org/"
EGIT_REPO_URI=( {https,git}://github.com/sardemff7/${PN}.git )

LICENSE="GPL-3+ LGPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug fbcon +introspection ipv6 libcanberra libnotify +notification
	purple sound speech ssdp systemd test websocket +X zeroconf"

REQUIRED_USE="
	X? ( notification )
	fbcon? ( notification )
	notification? ( || ( X fbcon ) )
"

COMMON_DEPEND="
	dev-libs/glib:2
	sys-apps/util-linux
	introspection? ( dev-libs/gobject-introspection )
	libcanberra? ( media-libs/libcanberra )
	libnotify? ( x11-libs/gdk-pixbuf:2 )
	notification? (
		x11-libs/cairo
		x11-libs/pango
		x11-libs/gdk-pixbuf:2
		X? (
			x11-libs/cairo[xcb]
			x11-libs/libxcb:=
			x11-libs/xcb-util
			x11-libs/xcb-util-wm
		)
	)
	purple? ( net-im/pidgin )
	sound? (
		media-libs/libsndfile
		media-sound/pulseaudio
	)
	speech? ( app-accessibility/speech-dispatcher )
	ssdp? ( net-libs/gssdp:= )
	systemd? ( sys-apps/systemd:= )
	websocket? ( net-libs/libsoup:2.4 )
	zeroconf? ( net-dns/avahi[dbus] )
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig
	fbcon? ( virtual/os-headers )
"
RDEPEND="${COMMON_DEPEND}
	net-libs/glib-networking[ssl]
"

pkg_setup() {
	if use kernel_linux && use ipv6; then
		if ! use test; then
			CONFIG_CHECK="~IPV6"
		else
			CONFIG_CHECK="IPV6"
		fi

		linux-info_pkg_setup
	fi
}

src_prepare() {
	default_src_prepare

	# Workaround Gentoo bug 604398.
	sed -i \
		-e 's|libspeechd|speech-dispatcher/libspeechd|g' \
		plugins/tts/src/tts.c || die

	eautoreconf
}

# Wayland plugin requires wayland-wall, which is currently WIP.
# See https://github.com/wayland-wall/wayland-wall/issues/1
src_configure() {
	local myeconfargs=(
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		--with-dbussessionservicedir="${EPREFIX}/usr/share/dbus-1/services"
		$(use_enable websocket)
		$(use_enable zeroconf dns-sd)
		$(use_enable ssdp)
		$(use_enable introspection)
		$(use_enable ipv6)
		$(use_enable systemd)
		$(use_enable notification notification-daemon)
		--disable-nd-wayland
		$(use_enable X nd-xcb)
		$(use_enable fbcon nd-fbdev)
		$(use_enable purple im)
		$(use_enable sound)
		$(use_enable speech tts)
		$(use_enable libnotify)
		$(use_enable libcanberra)
		$(use_enable debug)
	)
	econf "${myeconfargs[@]}"
}

src_test() {
	export EVENTD_TESTS_TMP_DIR="${T}"
	default_src_test
}

pkg_postinst() {
	if ! has_version 'gnome-base/librsvg'; then
		elog
		elog "For SVG icons, please install 'gnome-base/librsvg'."
		elog
	fi
}

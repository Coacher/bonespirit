# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools gnome2-utils git-r3

DESCRIPTION="PulseAudio system tray"
HOMEPAGE="https://github.com/christophgysin/pasystray"
EGIT_REPO_URI=( {https,git}://github.com/christophgysin/${PN}.git )

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="appindicator gtk3 libnotify zeroconf X"

RDEPEND="
	!gtk3? (
		x11-libs/gtk+:2
		appindicator? ( dev-libs/libappindicator:2 )
	)
	gtk3? (
		x11-libs/gtk+:3
		appindicator? ( dev-libs/libappindicator:3 )
	)
	libnotify? ( x11-libs/libnotify )
	zeroconf? ( net-dns/avahi )
	X? ( x11-libs/libX11 )
	dev-libs/glib
	media-sound/pulseaudio[glib,zeroconf?]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	default_src_prepare
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-statusicon
		--with-gtk=$(usex !gtk3 2 3)
		$(use_enable appindicator)
		$(use_enable libnotify notify)
		$(use_enable zeroconf avahi)
		$(use_enable X x11)
	)
	econf "${myeconfargs[@]}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

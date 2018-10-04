# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

XORG_DRI=dri

inherit xorg-2

DESCRIPTION="X.Org driver for Intel cards"
KEYWORDS="~amd64 ~x86"
IUSE="debug +sna +tools +udev ums uxa xvmc"

RDEPEND="
	>=x11-base/xorg-server-1.15
	>=x11-libs/libdrm-2.4.52[video_cards_intel]
	>=x11-libs/pixman-0.27.1
	tools? (
		x11-libs/libX11
		x11-libs/libXScrnSaver
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXtst
		x11-libs/libxcb
		x11-libs/libxshmfence
	)
	udev? ( virtual/libudev )
	ums? ( x11-libs/libpciaccess )
	xvmc? (
		x11-libs/libX11
		x11-libs/libXv
		x11-libs/libXvMC
		x11-libs/libxcb
		x11-libs/xcb-util
	)
"
DEPEND="${RDEPEND}
	>=x11-libs/libpciaccess-0.10
	>=x11-libs/libxcb-1.10
	x11-base/xorg-proto
	x11-misc/util-macros
"

REQUIRED_USE="|| ( sna uxa )"

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable debug)
		$(use_enable dri)
		$(use_enable sna)
		$(use_enable tools)
		$(use_enable tools backlight-helper)
		$(use_enable udev)
		$(use_enable ums)
		$(use_enable uxa)
		$(use_enable xvmc)
		$(usex dri '--with-default-dri=3')
		--disable-dri1
	)
	xorg-2_src_configure
}

# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

XORG_DRI=dri

inherit xorg-2

DESCRIPTION="X.Org driver for Intel cards"
KEYWORDS="~amd64 ~x86"
IUSE="debug dri3 +sna +tools +udev ums uxa xvmc"

RDEPEND="
	>=x11-libs/libdrm-2.4.52[video_cards_intel]
	>=x11-libs/pixman-0.27.1
	dri3? ( >=x11-base/xorg-server-1.15 )
	sna? ( >=x11-base/xorg-server-1.10 )
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
	>=x11-proto/dri2proto-2.6
	x11-misc/util-macros
	x11-proto/fontsproto
	x11-proto/presentproto
	x11-proto/videoproto
	x11-proto/xextproto
	x11-proto/xf86driproto
	x11-proto/xproto
	dri3? ( x11-proto/dri3proto )
	uxa? ( x11-proto/randrproto )
"

REQUIRED_USE="|| ( sna uxa )"

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable debug)
		$(use_enable dri)
		$(use_enable dri3)
		$(use_enable sna)
		$(use_enable tools)
		$(use_enable tools backlight-helper)
		$(use_enable udev)
		$(use_enable ums)
		$(use_enable uxa)
		$(use_enable xvmc)
		$(usex dri3 '--with-default-dri=3')
	)
	xorg-2_src_configure
}

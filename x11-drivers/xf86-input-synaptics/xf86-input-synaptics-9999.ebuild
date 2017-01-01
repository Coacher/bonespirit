# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit linux-info xorg-2

DESCRIPTION="Synaptics touchpad input driver"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=x11-base/xorg-server-1.14
	>=x11-libs/libXi-1.2
	>=x11-libs/libXtst-1.1.0
	kernel_linux? ( dev-libs/libevdev )
"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-2.6.37
	>=x11-proto/inputproto-2.1.99.3
	>=x11-proto/recordproto-1.14
	x11-proto/randrproto
"

pkg_pretend() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INPUT_EVDEV"
	fi
	check_extra_config
}

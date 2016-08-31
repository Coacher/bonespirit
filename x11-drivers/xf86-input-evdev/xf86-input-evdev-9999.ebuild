# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit linux-info xorg-2

DESCRIPTION="Generic Linux input driver"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=x11-base/xorg-server-1.18[udev]
	dev-libs/libevdev
	sys-libs/mtdev
"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-2.6
	>=x11-proto/inputproto-2.1.99.3
"

pkg_pretend() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INPUT_EVDEV"
	fi
	check_extra_config
}
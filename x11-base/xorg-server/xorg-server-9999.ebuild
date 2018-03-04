# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

XORG_DOC=doc

inherit multilib toolchain-funcs xorg-2

DESCRIPTION="X.Org X servers"
EGIT_REPO_URI="https://anongit.freedesktop.org/git/xorg/xserver.git"

SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE_SERVERS="dmx kdrive wayland xephyr xnest xorg xvfb"
IUSE="${IUSE_SERVERS} debug +glamor ipv6 libressl minimal selinux systemd +udev unwind xcsecurity"

COMMON_DEPEND="
	>=app-eselect/eselect-opengl-1.3.0
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	>=x11-libs/libdrm-2.4.89
	>=x11-libs/libpciaccess-0.12.901
	>=x11-libs/libxshmfence-1.1
	>=x11-libs/pixman-0.27.2
	>=x11-libs/xtrans-1.3.5
	x11-apps/xkbcomp
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXfont2
	x11-libs/libxkbfile
	x11-misc/xbitmaps
	x11-misc/xkeyboard-config
	dmx? (
		>=x11-libs/libX11-1.6
		>=x11-libs/libXext-1.0.99.4
		>=x11-libs/libXi-1.2.99.1
		>=x11-libs/libXtst-1.0.99.2
		>=x11-libs/libdmx-1.0.99.1
		x11-libs/libXaw
		x11-libs/libXfixes
		x11-libs/libXmu
		x11-libs/libXrender
		x11-libs/libXres
		x11-libs/libXt
	)
	glamor? (
		media-libs/libepoxy[X]
		media-libs/mesa[egl,gbm]
		!x11-libs/glamor
	)
	kdrive? (
		>=x11-libs/libXext-1.0.99.4
		x11-libs/libXv
	)
	xephyr? (
		x11-libs/libxcb[xkb]
		x11-libs/xcb-util
		x11-libs/xcb-util-image
		x11-libs/xcb-util-keysyms
		x11-libs/xcb-util-renderutil
		x11-libs/xcb-util-wm
	)
	!minimal? (
		>=x11-libs/libX11-1.6
		>=x11-libs/libXext-1.0.99.4
		media-libs/mesa
	)
	udev? ( virtual/udev )
	unwind? ( sys-libs/libunwind )
	wayland? (
		>=dev-libs/wayland-1.3.0
		>=dev-libs/wayland-protocols-1.1
		media-libs/libepoxy
	)
	systemd? (
		sys-apps/dbus
		sys-apps/systemd
	)
"
DEPEND="${COMMON_DEPEND}
	sys-devel/flex
	>=x11-base/xorg-proto-2018.3
	dmx? (
		doc? (
			|| (
				www-client/links
				www-client/lynx
				www-client/w3m
			)
		)
	)
"
RDEPEND="${COMMON_DEPEND}
	>=x11-apps/iceauth-1.0.2
	>=x11-apps/rgb-1.0.3
	>=x11-apps/xauth-1.0.3
	>=x11-apps/xinit-1.3.3-r1
	selinux? ( sec-policy/selinux-xserver )
	!x11-drivers/xf86-video-modesetting
"
PDEPEND="xorg? ( x11-base/xorg-drivers )"

REQUIRED_USE="
	!minimal? ( || ( ${IUSE_SERVERS} ) )
	xephyr? ( kdrive )
"

PATCHES=(
	"${FILESDIR}/${PN}-1.12-unload-submodule.patch"
	# Needed for newer eselect-opengl, see Gentoo bug 541232.
	"${FILESDIR}/${PN}-1.18-support-multiple-Files-sections.patch"
)

src_configure() {
	# localstatedir is used for log files; we need to override the default.
	# sysconfdir is used for the xorg.conf; same applies.
	XORG_CONFIGURE_OPTIONS=(
		--sysconfdir="${EPREFIX}/etc/X11"
		--localstatedir="${EPREFIX}/var"
		--with-fontrootdir="${EPREFIX}/usr/share/fonts"
		--with-xkb-output="${EPREFIX}/var/lib/xkb"
		--disable-config-hal
		--enable-libdrm
		--disable-linux-acpi
		--disable-linux-apm
		--enable-suid-wrapper
		--without-fop
		--without-dtrace
		--with-os-vendor=Gentoo
		--with-sha1=libcrypto
		$(use_enable debug)
		$(use_enable !minimal record)
		$(use_enable !minimal glx)
		$(use_enable !minimal dri)
		$(use_enable !minimal dri2)
		$(use_enable !minimal dri3)
		$(use_enable !minimal present)
		$(use_enable !minimal xfree86-utils)
		$(use_enable xcsecurity)
		$(use_enable udev config-udev)
		$(use_enable systemd systemd-logind)
		$(use_enable xorg)
		$(use_enable dmx)
		$(use_enable xvfb)
		$(use_enable xnest)
		$(use_enable wayland xwayland)
		$(use_enable glamor)
		$(use_enable kdrive)
		$(use_enable xephyr)
		$(use_enable unwind libunwind)
		$(use_enable ipv6)
		$(use_with doc doxygen)
		$(use_with doc xmlto)
		$(use_with systemd systemd-daemon)
	)
	xorg-2_src_configure
}

src_install() {
	xorg-2_src_install

	server_based_install

	if ! use minimal && use xorg; then
		dodoc "${BUILD_DIR}"/hw/xfree86/xorg.conf.example
	fi

	newinitd "${FILESDIR}"/xdm-setup.initd-1 xdm-setup
	newinitd "${FILESDIR}"/xdm.initd-11 xdm
	newconfd "${FILESDIR}"/xdm.confd-4 xdm

	insinto /usr/share/portage/config/sets
	newins "${FILESDIR}"/xorg-sets.conf xorg.conf
}

server_based_install() {
	if ! use xorg; then
		rm \
			"${ED}"/usr/share/man/man1/Xserver.1x \
			"${ED}"/usr/$(get_libdir)/xserver/SecurityPolicy \
			"${ED}"/usr/$(get_libdir)/pkgconfig/xorg-server.pc \
			"${ED}"/usr/share/man/man1/Xserver.1x || die
	fi
}

pkg_postinst() {
	# Set up libGL and DRI symlinks if needed (e.g. on a fresh install).
	eselect opengl set xorg-x11 --use-old
}

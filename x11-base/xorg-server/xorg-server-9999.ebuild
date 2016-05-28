# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

XORG_DOC=doc

inherit xorg-2 multilib toolchain-funcs

DESCRIPTION="X.Org X servers"
EGIT_REPO_URI="git://anongit.freedesktop.org/xorg/xserver"
EGIT_COMMIT="8cf832c288dec13cbf3c25478a8ccef52d61f3db"

SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE_SERVERS="dmx kdrive xephyr xnest xorg xvfb"
IUSE="${IUSE_SERVERS} glamor ipv6 libressl minimal selinux +suid systemd tslib +udev unwind wayland"

COMMON_DEPEND="
	>=app-eselect/eselect-opengl-1.3.0
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:= )
	media-libs/freetype
	x11-apps/xkbcomp
	>=x11-libs/libdrm-2.4.46
	>=x11-libs/libpciaccess-0.12.901
	>=x11-libs/libXau-1.0.4
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXfont-1.4.2
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/libxshmfence-1.1
	>=x11-libs/pixman-0.27.2
	>=x11-libs/xtrans-1.3.5
	>=x11-misc/xbitmaps-1.0.1
	>=x11-misc/xkeyboard-config-2.4.1-r3
	dmx? (
		>=x11-libs/libdmx-1.0.99.1
		>=x11-libs/libX11-1.1.5
		>=x11-libs/libXaw-1.0.4
		>=x11-libs/libXext-1.0.99.4
		>=x11-libs/libXfixes-5.0
		>=x11-libs/libXi-1.2.99.1
		>=x11-libs/libXmu-1.0.3
		>=x11-libs/libXres-1.0.3
		>=x11-libs/libXtst-1.0.99.2
		x11-libs/libXrender
		x11-libs/libXt
	)
	glamor? (
		media-libs/libepoxy
		>=media-libs/mesa-10.3.4-r1[egl,gbm]
		!x11-libs/glamor
	)
	kdrive? (
		>=x11-libs/libXext-1.0.99.4
		x11-libs/libXv
	)
	xephyr? (
		x11-libs/libxcb
		x11-libs/xcb-util
		x11-libs/xcb-util-image
		x11-libs/xcb-util-keysyms
		x11-libs/xcb-util-renderutil
		x11-libs/xcb-util-wm
	)
	!minimal? (
		>=x11-libs/libX11-1.1.5
		>=x11-libs/libXext-1.0.99.4
		>=media-libs/mesa-10.3.4-r1
	)
	tslib? ( >=x11-libs/tslib-1.0 )
	udev? ( >=virtual/udev-150 )
	unwind? ( sys-libs/libunwind )
	wayland? (
		>=dev-libs/wayland-1.3.0
		media-libs/libepoxy
	)
	systemd? (
		sys-apps/dbus
		sys-apps/systemd
	)
"
DEPEND="${COMMON_DEPEND}
	sys-devel/autoconf-archive
	sys-devel/flex
	>=x11-proto/bigreqsproto-1.1.0
	>=x11-proto/compositeproto-0.4
	>=x11-proto/damageproto-1.1
	>=x11-proto/fixesproto-5.0
	>=x11-proto/fontsproto-2.1.3
	>=x11-proto/inputproto-2.3
	>=x11-proto/kbproto-1.0.3
	>=x11-proto/randrproto-1.5.0
	>=x11-proto/renderproto-0.11
	>=x11-proto/resourceproto-1.2.0
	>=x11-proto/scrnsaverproto-1.1
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/xcmiscproto-1.2.0
	>=x11-proto/xextproto-7.2.99.901
	>=x11-proto/xf86dgaproto-2.0.99.1
	>=x11-proto/xf86vidmodeproto-2.2.99.1
	>=x11-proto/xineramaproto-1.1.3
	>=x11-proto/xproto-7.0.28
	dmx? (
		>=x11-proto/dmxproto-2.2.99.1
		doc? (
			|| (
				www-client/links
				www-client/lynx
				www-client/w3m
			)
		)
	)
	!minimal? (
		>=x11-proto/dri2proto-2.8
		>=x11-proto/dri3proto-1.0
		>=x11-proto/glproto-1.4.17-r1
		>=x11-proto/presentproto-1.0
		>=x11-proto/recordproto-1.13.99.1
		>=x11-proto/xf86driproto-2.1.0
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

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != "binary" ]] && [[ $(gcc-major-version) -lt 4 ]]; then
		die "Your compiler isn't supported. Use GCC >= 4."
	fi
}

src_configure() {
	# localstatedir is used for log files; we need to override the default.
	# sysconfdir is used for the xorg.conf; same applies.
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable !minimal record)
		$(use_enable !minimal glx)
		$(use_enable !minimal dri)
		$(use_enable !minimal dri2)
		$(use_enable !minimal dri3)
		$(use_enable !minimal present)
		$(use_enable !minimal xfree86-utils)
		$(use_enable tslib)
		$(use_enable udev config-udev)
		$(use_enable systemd systemd-logind)
		$(use_enable xorg)
		$(use_enable dmx)
		$(use_enable xvfb)
		$(use_enable xnest)
		$(use_enable wayland xwayland)
		$(use_enable glamor)
		$(use_enable xephyr)
		$(use_enable kdrive)
		$(use_enable kdrive kdrive-kbd)
		$(use_enable kdrive kdrive-mouse)
		$(use_enable kdrive kdrive-evdev)
		$(use_enable unwind libunwind)
		$(use_enable suid install-setuid)
		$(use_enable ipv6)
		$(use_with doc doxygen)
		$(use_with doc xmlto)
		$(use_with systemd systemd-daemon)
		--sysconfdir="${EPREFIX}/etc/X11"
		--localstatedir="${EPREFIX}/var"
		--with-fontrootdir="${EPREFIX}/usr/share/fonts"
		--with-xkb-output="${EPREFIX}/var/lib/xkb"
		--enable-libdrm
		--disable-config-hal
		--disable-linux-acpi
		--disable-linux-apm
		--without-fop
		--without-dtrace
		--with-os-vendor=Gentoo
		--with-sha1=libcrypto
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

pkg_postinst() {
	# Set up libGL and DRI symlinks if needed (e.g. on a fresh install).
	eselect opengl set xorg-x11 --use-old
}

pkg_postrm() {
	# Remove modules directory to ensure opengl-update works properly.
	if [[ -z ${REPLACED_BY_VERSION} ]] && [[ -e "${EROOT}/usr/$(get_libdir)/xorg/modules" ]]; then
		rm -rf "${EROOT}"/usr/$(get_libdir)/xorg/modules || die
	fi
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

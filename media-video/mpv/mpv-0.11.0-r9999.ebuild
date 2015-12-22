# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
PYTHON_REQ_USE='threads(+)'

WAF_PV='1.8.12'

inherit eutils fdo-mime gnome2-utils pax-utils python-any-r1 waf-utils

DESCRIPTION="Media player based on MPlayer and mplayer2"
HOMEPAGE="https://mpv.io/"
SRC_URI="https://waf.io/pub/release/waf-${WAF_PV}"

if [[ ${PV} != *9999* ]]; then
	SRC_URI+=" https://github.com/mpv-player/mpv/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux"
	DOCS=( RELEASE_NOTES )
else
	EGIT_REPO_URI="https://github.com/mpv-player/mpv.git"
	inherit git-r3
fi
DOCS+=( README.md etc/example.conf etc/input.conf )

# See Copyright in source tarball and bug #506946. Waf is BSD, libmpv is ISC.
LICENSE="GPL-2+ BSD ISC"
SLOT="0"
# Here 'opengl' stands for GLX, 'egl' stands for any EGL-based output
IUSE="+alsa archive bluray cdda +cli doc drm dvb +dvd egl +enca encode +iconv
jack jpeg lcms +libass libav libcaca libguess libmpv lua luajit openal +opengl
oss pulseaudio pvr raspberry-pi rubberband samba sdl selinux test v4l vaapi
vdpau vf-dlopen wayland +X xinerama +xscreensaver xv"

REQUIRED_USE="
	|| ( cli libmpv )
	egl? ( || ( X wayland ) )
	enca? ( iconv )
	libguess? ( iconv )
	luajit? ( lua )
	opengl? ( X )
	pvr? ( v4l )
	v4l? ( || ( alsa oss ) )
	vaapi? ( X )
	vdpau? ( X )
	wayland? ( egl )
	xinerama? ( X )
	xscreensaver? ( X )
	xv? ( X )
"

CDEPEND="
	!libav? ( >=media-video/ffmpeg-2.4.0:0=[encode?,threads,vaapi?,vdpau?] )
	libav? ( >=media-video/libav-11:0=[encode?,threads,vaapi?,vdpau?] )
	sys-libs/zlib
	alsa? ( >=media-libs/alsa-lib-1.0.18 )
	archive? ( >=app-arch/libarchive-3.0.0:= )
	bluray? ( >=media-libs/libbluray-0.3.0 )
	cdda? ( dev-libs/libcdio-paranoia )
	drm? ( x11-libs/libdrm )
	dvb? ( virtual/linuxtv-dvb-headers )
	dvd? (
		>=media-libs/libdvdnav-4.2.0
		>=media-libs/libdvdread-4.1.0
	)
	egl? ( media-libs/mesa[egl,wayland(-)?] )
	enca? ( app-i18n/enca )
	iconv? ( virtual/libiconv )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg? ( virtual/jpeg:0 )
	lcms? ( >=media-libs/lcms-2.6:2 )
	libass? (
		>=media-libs/libass-0.12.1:=[fontconfig,harfbuzz]
		virtual/ttf-fonts
	)
	libcaca? ( >=media-libs/libcaca-0.99_beta18 )
	libguess? ( >=app-i18n/libguess-1.0 )
	lua? (
		!luajit? ( || ( =dev-lang/lua-5.1*:= =dev-lang/lua-5.2*:= ) )
		luajit? ( dev-lang/luajit:2 )
	)
	openal? ( >=media-libs/openal-1.13 )
	pulseaudio? ( media-sound/pulseaudio )
	rubberband? ( >=media-libs/rubberband-1.8.0 )
	samba? ( net-fs/samba )
	sdl? ( media-libs/libsdl2[sound,threads,video,wayland?,X?] )
	v4l? ( media-libs/libv4l )
	wayland? (
		>=dev-libs/wayland-1.6.0
		>=x11-libs/libxkbcommon-0.3.0
	)
	X? (
		x11-libs/libX11
		x11-libs/libXext
		>=x11-libs/libXrandr-1.2.0
		opengl? (
			x11-libs/libXdamage
			virtual/opengl
		)
		vaapi? ( >=x11-libs/libva-1.2.0[X(+)] )
		vdpau? ( >=x11-libs/libvdpau-0.2 )
		xinerama? ( x11-libs/libXinerama )
		xscreensaver? ( x11-libs/libXScrnSaver )
		xv? ( x11-libs/libXv )
	)
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.8
	dev-python/docutils
	virtual/pkgconfig
	doc? ( dev-python/rst2pdf )
	test? ( >=dev-util/cmocka-1.0.0 )
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-mplayer )
"

pkg_pretend() {
	if ! use libass; then
		ewarn "You have disabled the libass flag. No OSD or subtitles will be displayed."
	fi

	if use openal; then
		ewarn "You have enabled the openal audio output, which is a fallback"
		ewarn "and disabled by upstream."
	fi

	if use sdl; then
		ewarn "You have enabled the sdl video and audio outputs, which are fallbacks"
		ewarn "and disabled by upstream."
	fi

	if use libav; then
		einfo "You have enabled media-video/libav instead of media-video/ffmpeg."
		einfo "Upstream recommends media-video/ffmpeg, as some functionality is not"
		einfo "provided by media-video/libav."
	fi

	einfo "mpv optionally supports many different audio and video formats."
	einfo "You will need to enable support for the desired formats in your"
	einfo "libavcodec/libavformat provider:"
	einfo "    media-video/ffmpeg or media-video/libav"
}

src_prepare() {
	cp "${DISTDIR}/waf-${WAF_PV}" "${S}"/waf || die
	chmod 0755 "${S}"/waf || die

	epatch "${FILESDIR}/${PN}-fix-include-in-tests.patch"
	epatch_user
}

src_configure() {
	local mywafargs=(
		--confdir="${EPREFIX}"/etc/${PN}
		--docdir="${EPREFIX}"/usr/share/doc/${PF}

		$(usex cli '' '--disable-cplayer')
		$(use_enable libmpv libmpv-shared)

		--disable-libmpv-static
		--disable-static-build
		--disable-build-date	# Create reproducible build
		--disable-optimize		# Do not add '-O2' to CFLAGS
		--disable-debug-build	# Do not add '-g' to CFLAGS

		$(use_enable doc pdf-build)
		$(use_enable vf-dlopen vf-dlopen-filters)
		$(use_enable cli zsh-comp)
		$(use_enable test)

		$(use_enable iconv)
		$(use_enable samba libsmbclient)
		$(use_enable lua)
		$(usex luajit '--lua=luajit' '')
		$(use_enable libass)
		$(use_enable libass libass-osd)
		$(use_enable encode encoding)
		$(use_enable bluray libbluray)
		$(use_enable dvd dvdread)
		$(use_enable dvd dvdnav)
		$(use_enable cdda)
		$(use_enable enca)
		$(use_enable libguess)
		--disable-uchardet		# Disable uchardet until #569114 is fixed
		$(use_enable rubberband)
		$(use_enable lcms lcms2)
		--disable-vapoursynth	# Only available in overlays
		--disable-vapoursynth-lazy
		$(use_enable archive libarchive)

		--enable-libavfilter
		--enable-libavdevice

		# Audio outputs
		$(use_enable sdl sdl2)	# Listed under audio, but also includes video
		--disable-sdl1
		$(use_enable oss oss-audio)
		--disable-rsound		# Only available in overlays
		$(use_enable pulseaudio pulse)
		$(use_enable jack)
		$(use_enable openal)
		$(use_enable alsa)
		--disable-coreaudio
		--disable-dsound
		--disable-wasapi

		# Video outputs
		--disable-cocoa
		$(use_enable wayland)
		$(use_enable X x11)
		$(use_enable xscreensaver xss)
		$(use_enable X xext)
		$(use_enable xv)
		$(use_enable xinerama)
		$(use_enable X xrandr)
		$(use_enable opengl gl-x11)
		$(usex egl "$(use_enable X egl-x11)" '--disable-egl-x11')
		$(use_enable wayland gl-wayland)
		$(use_enable vdpau)
		$(usex vdpau "$(use_enable opengl vdpau-gl-x11)" '--disable-vdpau-gl-x11')
		$(use_enable vaapi)
		$(use_enable vaapi vaapi-vpp)
		$(usex vaapi "$(use_enable opengl vaapi-glx)" '--disable-vaapi-glx')
		$(use_enable libcaca caca)
		$(use_enable drm)
		$(use_enable jpeg)
		$(use_enable raspberry-pi rpi)

		# HWaccels
		$(use_enable vaapi vaapi-hwaccel)
		$(use_enable vdpau vdpau-hwaccel)

		# TV features
		$(use_enable v4l tv)
		$(use_enable v4l tv-v4l2)
		$(use_enable v4l libv4l2)
		$(use_enable v4l audio-input)
		$(use_enable pvr)
		$(use_enable dvb dvbin)
	)
	waf-utils_src_configure "${mywafargs[@]}"
}

src_install() {
	waf-utils_src_install

	if use cli && use luajit; then
		pax-mark -m "${ED}usr/bin/${PN}"
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

src_test() {
	cd "${S}"/build/test || die
	for test in *; do
		if [ -x "${test}" ]; then
			$(${test}) || die "Test suite failed"
		fi
	done
}
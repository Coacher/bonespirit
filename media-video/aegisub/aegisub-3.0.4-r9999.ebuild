# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PLOCALES="ar ca cs da de el es eu fa fi fr_FR hu id it ja ko nl pl pt_BR pt_PT ru sr_RS@latin sr_RS vi zh_CN zh_TW"
WX_GTK_VER=2.9

inherit autotools fdo-mime gnome2-utils l10n wxwidgets

DESCRIPTION="Advanced subtitle editor"
HOMEPAGE="http://www.aegisub.org/ https://github.com/Aegisub/Aegisub"
SRC_URI="
	http://ftp.aegisub.org/pub/releases/${P}.tar.xz
	ftp://ftp.aegisub.org/pub/releases/${P}.tar.xz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa debug +ffmpeg +fftw +libass lua openal oss portaudio pulseaudio spell"

# configure.ac specifies minimal versions for some of the dependencies below.
# However, most of these minimal versions date back to 2006-2012 yy.
# Such version specifiers are meaningless nowadays, so they are omitted.
RDEPEND="
	>=x11-libs/wxGTK-2.9.3:${WX_GTK_VER}[X,opengl,debug?]
	media-libs/fontconfig
	media-libs/freetype
	virtual/libiconv
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	ffmpeg? ( media-libs/ffmpegsource:= )
	fftw? ( >=sci-libs/fftw-3.3:= )
	libass? ( media-libs/libass:=[fontconfig] )
	lua? ( =dev-lang/lua-5.1*:= )
	openal? ( media-libs/openal )
	portaudio? ( =media-libs/portaudio-19* )
	pulseaudio? ( media-sound/pulseaudio )
	spell? ( app-text/hunspell )
"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	oss? ( virtual/os-headers )
"

REQUIRED_USE="|| ( alsa openal oss portaudio pulseaudio )"

PATCHES=(
	"${FILESDIR}/${P}-fix-lua-macro.patch"
	"${FILESDIR}/${P}-fix-install-with-empty-LINGUAS.patch"
	"${FILESDIR}/${P}-respect-user-compiler-flags.patch"
)

S="${WORKDIR}/${PN}/${PN}"

src_prepare() {
	default_src_prepare

	remove_locale() {
		sed -i -e "s/${1}\.po//g" po/Makefile || die
	}

	l10n_find_plocales_changes 'po' '' '.po'
	l10n_for_each_disabled_locale_do remove_locale

	# See http://devel.aegisub.org/ticket/1914
	config_rpath_update "${S}"/config.rpath

	eautoreconf
}

src_configure() {
	# Prevent sandbox violation from OpenAL detection. Gentoo bug 508184.
	use openal && export agi_cv_with_openal="yes"
	local myeconfargs=(
		--disable-crash-reporter
		--disable-update-checker
		$(use_enable debug)
		$(use_with alsa)
		$(use_with ffmpeg ffms2)
		$(use_with fftw fftw3)
		$(use_with libass)
		$(use_with lua)
		$(use_with openal)
		$(use_with oss)
		$(use_with portaudio)
		$(use_with pulseaudio libpulse)
		$(use_with spell hunspell)
	)
	econf "${myeconfargs[@]}"
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

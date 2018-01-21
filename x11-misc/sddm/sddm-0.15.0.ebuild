# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils systemd user

DESCRIPTION="Simple Desktop Display Manager"
HOMEPAGE="https://github.com/sddm/sddm"
SRC_URI="https://github.com/sddm/sddm/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="consolekit elogind +pam systemd"

RDEPEND="
	>=dev-qt/qtcore-5.6:5
	>=dev-qt/qtdbus-5.6:5
	>=dev-qt/qtdeclarative-5.6:5
	>=dev-qt/qtgui-5.6:5
	>=dev-qt/qtnetwork-5.6:5
	>=x11-base/xorg-server-1.15.1
	x11-libs/libxcb[xkb]
	consolekit? ( >=sys-auth/consolekit-0.9.4 )
	elogind? ( sys-auth/elogind )
	pam? ( sys-libs/pam )
	systemd? ( sys-apps/systemd:= )
	!systemd? ( || ( sys-power/upower sys-power/upower-pm-utils ) )
"
DEPEND="${RDEPEND}
	dev-python/docutils
	>=dev-qt/linguist-tools-5.6:5
	>=dev-qt/qttest-5.6:5
	kde-frameworks/extra-cmake-modules
	virtual/pkgconfig
"

REQUIRED_USE="?? ( elogind systemd )"

PATCHES=( "${FILESDIR}/${P}-respect-user-flags.patch" )

src_prepare() {
	use consolekit && eapply "${FILESDIR}/${P}-consolekit.patch"
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDBUS_CONFIG_FILENAME="org.freedesktop.sddm.conf"
		-DBUILD_MAN_PAGES=ON
		-DENABLE_PAM=$(usex pam)
		-DNO_SYSTEMD=$(usex !systemd)
		-DUSE_ELOGIND=$(usex elogind)
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/lib/${PN} ${PN},video

	systemd_reenable sddm.service

	if use consolekit && use pam && [[ -e "${ROOT}"/etc/pam.d/system-login ]]; then
		local line=$(grep "pam_ck_connector.*nox11" "${ROOT}"/etc/pam.d/system-login)
		if [[ -z ${line} ]]; then
			ewarn
			ewarn "Erroneous /etc/pam.d/system-login settings detected!"
			ewarn "Please restore 'nox11' option in the line containing pam_ck_connector:"
			ewarn
			ewarn "session      optional      pam_ck_connector.so nox11"
			ewarn
			ewarn "or 'emerge -1 sys-auth/pambase' and run etc-update."
			ewarn
		fi
	fi
}

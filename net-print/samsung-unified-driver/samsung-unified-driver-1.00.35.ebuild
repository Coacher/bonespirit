# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit linux-info udev vcs-snapshot

DESCRIPTION="Samsung Unified Linux Driver for printers and MFDs"
HOMEPAGE="http://www.samsung.com"
SRC_URI="http://downloadcenter.samsung.com/content/DR/201503/20150311142813858/ULD_v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Samsung-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="cups network scanner"

RDEPEND="
	cups? (
		net-print/cups
		!net-print/splix
	)
	scanner? (
		media-gfx/sane-backends
		dev-libs/libxml2:2
		virtual/libusb:0
	)
	network? ( virtual/libusb:0 )
"

REQUIRED_USE="
	network? ( cups )
	|| ( cups scanner )
"

RESTRICT="mirror strip"

pkg_pretend() {
	if use scanner && ! has_version ${CATEGORY}/${PN}[scanner]; then
		if ! linux_config_exists || linux_chkconfig_present USB_PRINTER; then
			ewarn "Samsung USB MFDs are normally managed via libusb."
			ewarn "In this case, you need to either disable the USB_PRINTER"
			ewarn "support in your kernel, or blacklist the 'usblp' module."
		fi
	fi
}

pkg_setup() {
	if use cups; then
		QA_SONAME="usr/$(get_libdir)/libscmssc.so"
		QA_FLAGS_IGNORED+=" usr/$(get_libdir)/libscmssc.so"
		QA_FLAGS_IGNORED+=" usr/libexec/cups/filter/pstosecps"
		QA_FLAGS_IGNORED+=" usr/libexec/cups/filter/rastertospl"
	fi
	if use scanner; then
		QA_FLAGS_IGNORED+=" usr/$(get_libdir)/sane/libsane-smfp.so.1.0.1"
	fi
	if use network; then
		QA_FLAGS_IGNORED+=" usr/libexec/cups/backend/smfpnetdiscovery"
	fi
}

src_install() {
	local MY_ARCH="x86_64"
	use x86 && MY_ARCH="x86"

	# Printer support.
	if use cups; then
		# libscmssc.so is required by rastertospl.
		dolib.so ${MY_ARCH}/libscmssc.so

		exeinto /usr/libexec/cups/filter
		doexe ${MY_ARCH}/{pstosecps,rastertospl}

		dodir /usr/share/cups/model/samsung
		insinto /usr/share/cups/model/samsung
		doins noarch/share/ppd/*.ppd
		gzip -9 "${ED}"usr/share/cups/model/samsung/*.ppd || die

		dodir /usr/share/cups/profiles/samsung
		insinto /usr/share/cups/profiles/samsung
		doins noarch/share/ppd/cms/*.cts
	fi

	# Scanner support.
	if use scanner; then
		insinto /etc/sane.d
		doins noarch/etc/smfp.conf

		dodir /opt/samsung/scanner/share
		insinto /opt/samsung/scanner/share
		doins noarch/oem.conf

		exeinto /usr/$(get_libdir)/sane
		doexe ${MY_ARCH}/libsane-smfp.so.1.0.1

		dosym libsane-smfp.so.1.0.1 /usr/$(get_libdir)/sane/libsane-smfp.so
		dosym libsane-smfp.so.1.0.1 /usr/$(get_libdir)/sane/libsane-smfp.so.1

		udev_newrules "${FILESDIR}/${PV}-libsane-smfp.rules" 40-libsane-smfp.rules
	fi

	# Network support.
	if use network; then
		exeinto /usr/libexec/cups/backend
		doexe ${MY_ARCH}/smfpnetdiscovery
	fi
}

pkg_postinst() {
	if use scanner && ! has_version ${CATEGORY}/${PN}[scanner]; then
		elog "You need to manually add 'smfp' backend to /etc/sane.d/dll.conf:"
		elog "# echo smfp >> /etc/sane.d/dll.conf"
	fi
	if use network && ! has_version ${CATEGORY}/${PN}[network]; then
		elog "If you are behind a firewall, you need to allow SNMP UDP packets"
		elog "with source port 161 and destination port 22161."
	fi
}

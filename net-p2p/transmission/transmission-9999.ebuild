# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3 gnome2-utils readme.gentoo-r1 user xdg-utils

EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"

DESCRIPTION="A fast, easy, and free BitTorrent client"
HOMEPAGE="https://transmissionbt.com/"

# web/LICENSE is always GPL-2 whereas COPYING allows either GPL-2 or GPL-3 for the rest
# transmission in licenses/ is for mentioning OpenSSL linking exception
# MIT is in several libtransmission/ headers
LICENSE="|| ( GPL-2 GPL-3 Transmission-OpenSSL-exception ) GPL-2 MIT"
SLOT="0"
IUSE="ayatana gtk libressl lightweight nls mbedtls qt5 test +xfs"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/libevent-2.0.10:=
	!mbedtls? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	mbedtls? ( net-libs/mbedtls:0= )
	>=net-misc/curl-7.16.3[ssl]
	sys-libs/zlib:=
	gtk? (
		>=dev-libs/dbus-glib-0.100
		>=dev-libs/glib-2.32:2
		>=x11-libs/gtk+-3.4:3
		ayatana? ( >=dev-libs/libappindicator-0.4.30:3 )
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtnetwork:5
		dev-qt/qtdbus:5
	)
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? (
		virtual/libintl
		gtk? (
			dev-util/intltool
			sys-devel/gettext
		)
		qt5? (
			dev-qt/linguist-tools:5
		)
	)
"

src_prepare() {
	# 2.92+ -> 2.92
	sed -i s/2.92+/2.92/g CMakeLists.txt || die
	sed -i s/TR292Z/TR2920/g CMakeLists.txt || die
	sed -i s/2.92+/2.92/g configure.ac || die
	sed -i s/TR292Z/TR2920/g configure.ac || die

	default
}

src_configure() {
	export ac_cv_header_xfs_xfs_h=$(usex xfs)

	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR=share/doc/${PF}

		-DENABLE_GTK=$(usex gtk ON OFF)
		-DENABLE_LIGHTWEIGHT=$(usex lightweight ON OFF)
		-DENABLE_NLS=$(usex nls ON OFF)
		-DENABLE_QT=$(usex qt5 ON OFF)
		-DENABLE_TESTS=$(usex test ON OFF)
		-DUSE_QT5=ON

		-DUSE_SYSTEM_EVENT2=ON
		-DUSE_SYSTEM_DHT=OFF
		-DUSE_SYSTEM_MINIUPNPC=OFF
		-DUSE_SYSTEM_NATPMP=OFF
		-DUSE_SYSTEM_UTP=OFF
		-DUSE_SYSTEM_B64=OFF

		-DWITH_CRYPTO=$(usex mbedtls polarssl openssl)
		-DWITH_INOTIFY=ON
		-DWITH_LIBAPPINDICATOR=$(usex ayatana ON OFF)
		-DWITH_SYSTEMD=OFF
	)

	cmake-utils_src_configure
}

DISABLE_AUTOFORMATTING=1
DOC_CONTENTS="\
If you use transmission-daemon, please, set 'rpc-username' and
'rpc-password' (in plain text, transmission-daemon will hash it on
start) in settings.json file located at /var/lib/transmission/config or
any other appropriate config directory.

Since µTP is enabled by default, transmission needs large kernel buffers for
the UDP socket. You can append following lines into /etc/sysctl.conf:

net.core.rmem_max = 4194304
net.core.wmem_max = 1048576

and run sysctl -p"

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}"/transmission-daemon.initd.10 transmission-daemon
	newconfd "${FILESDIR}"/transmission-daemon.confd.4 transmission-daemon

	readme.gentoo_create_doc
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update

	readme.gentoo_print_elog
}

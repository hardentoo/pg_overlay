# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit kde5

DESCRIPTION="Mozilla KDE Desktop Integration"
HOMEPAGE="https://github.com/openSUSE/kmozillahelper"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/openSUSE/kmozillahelper.git"
	inherit git-r3
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/openSUSE/${PN}/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
IUSE=""

COMMON_DEPEND="
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kconfigwidgets)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kdbusaddons)
	$(add_frameworks_dep kguiaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep kservice)
	$(add_frameworks_dep kwidgetsaddons)
	$(add_frameworks_dep kwindowsystem)
	dev-qt/qtconcurrent:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
"
DEPEND="${COMMON_DEPEND}
	$(add_frameworks_dep kinit)
	dev-libs/mpfr:0
	sys-devel/gettext
	!kde-misc/kmozillahelper:4
"
RDEPEND="${COMMON_DEPEND}"

pkg_postinst() {
	ewarn "To suppress the taskbar icon for ${PN} file dialog window - install Kwin rule"
	ewarn "${FILESDIR}/kwinrulesrc to \"\${HOME}/.config/\""
}

# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk vi zh-CN zh-TW
"
inherit chromium-2 eutils multilib unpacker toolchain-funcs gnome2-utils xdg-utils

DESCRIPTION="A new browser for our friends"
HOMEPAGE="http://vivaldi.com/"
BASE_URI="https://downloads.vivaldi.com/snapshot/${PN}_${PV/_p/-}_"
SRC_URI="
	amd64? ( ${BASE_URI}amd64.deb )
	x86? ( ${BASE_URI}i386.deb )
"

LICENSE="Vivaldi"
SLOT="0"
KEYWORDS="-* amd64 x86"

RESTRICT="bindist mirror"
IUSE="+widevine"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	>=dev-libs/openssl-1.0.1:0
	gnome-base/gconf:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/libcap
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango[X]
	widevine? ( www-plugins/chrome-binary-plugins[widevine] )
"

S=${WORKDIR}

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	rm -r \
		etc/ \
		usr/bin/ \
		opt/${PN}/cron/ || die
	rm _gpgbuilder || die
	if use widevine; then
		rm opt/${PN}/libwidevinecdm.so || die
		ln -s \
			/usr/lib/chromium/libwidevinecdm.so \
			opt/${PN}/libwidevinecdm.so || die
	fi

	local d
	for d in 16 22 24 32 48 64 128 256; do
		mkdir -p usr/share/icons/hicolor/${d}x${d}/apps || die
		cp \
			opt/${PN}/product_logo_${d}.png \
			usr/share/icons/hicolor/${d}x${d}/apps/${PN}.png || die
	done

	pushd "opt/${PN}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

}

src_install() {
	mv * "${D}" || die
	dosym /opt/${PN}/${PN} /usr/bin/${PN}

	fperms 4711 /opt/${PN}/vivaldi-sandbox
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
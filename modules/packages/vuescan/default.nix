{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  gtk3,
  glib,
  gdk-pixbuf,
  pango,
  cairo,
  libpng,
  libxkbcommon,
  util-linux,
  libx11,
  systemd,
  zlib,
  desktop-file-utils,
  coreutils,
}:

stdenv.mkDerivation rec {
  pname = "vuescan";
  version = "9.8.59";

  src = fetchurl {
    url = "https://files.hamrick.com/vuex6498.tgz";
    hash = "sha256-NKbmL0L9uM/GADHY61oCLopEr8yHuuM0Xem3q9l0Ao8=";
  };

  sourceRoot = "VueScan";
  # VueScan appends an internal resource archive (vuescan.dat, ~40MB) to the end
  # of the ELF binary. Standard strip removes it, causing an immediate null pointer dereference.
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gtk3
    glib
    gdk-pixbuf
    pango
    cairo
    libpng
    libxkbcommon
    util-linux
    libx11
    systemd
    zlib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 vuescan $out/bin/vuescan
    install -Dm644 vuescan.svg $out/share/icons/hicolor/scalable/apps/vuescan.svg
    install -Dm644 vuescan.rul $out/lib/udev/rules.d/60-vuescan.rules

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          desktop-file-utils
          coreutils
        ]
      }
    )
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vuescan";
      exec = "vuescan";
      icon = "vuescan";
      desktopName = "VueScan";
      genericName = "Scanning Software";
      comment = "Scan documents, photos, and film";
      categories = [
        "Graphics"
        "Scanning"
      ];
      startupNotify = true;
    })
  ];

  meta = with lib; {
    description = "Scanner software for photos, documents, and film";
    homepage = "https://www.hamrick.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "vuescan";
  };
}

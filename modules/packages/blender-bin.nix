{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  wayland,
  libdecor,
  libx11,
  libxi,
  libxxf86vm,
  libxfixes,
  libxrender,
  libsm,
  libice,
  libxkbcommon,
  libGLU,
  libglvnd,
  numactl,
  SDL2,
  libdrm,
  ocl-icd,
  openal,
  alsa-lib,
  pulseaudio,
  zlib,
  vulkan-loader,
}:

stdenv.mkDerivation rec {
  pname = "blender-bin";
  version = "5.3.0";

  src = fetchurl {
    url = "https://download.blender.org/release/Blender5.3/blender-${version}-linux-x64.tar.xz";
    hash = "sha256-2suCZBl6P3/aYAEoWlpQb8l+6UOIEmHCw71jyILyLgU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/blender" "$out/bin" "$out/share/applications" \
      "$out/share/icons/hicolor/scalable/apps"
    cp -a . "$out/libexec/blender/"
    install -m644 blender.desktop "$out/share/applications/blender.desktop"
    install -m644 blender.svg "$out/share/icons/hicolor/scalable/apps/blender.svg"

    patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" \
      "$out/libexec/blender/blender"
    patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" \
      "$out/libexec/blender/5.3/python/bin/python3.13"

    makeWrapper "$out/libexec/blender/blender" "$out/bin/blender" \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${
        lib.makeLibraryPath [
          wayland
          libdecor
          libx11
          libxi
          libxxf86vm
          libxfixes
          libxrender
          libsm
          libice
          libxkbcommon
          libGLU
          libglvnd
          numactl
          SDL2
          libdrm
          ocl-icd
          stdenv.cc.cc.lib
          openal
          alsa-lib
          pulseaudio
          zlib
          vulkan-loader
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "Official Blender binary release";
    homepage = "https://www.blender.org/";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "blender";
  };
}

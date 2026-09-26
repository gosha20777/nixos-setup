{
  lib,
  stdenv,
  python3Packages,
  makeWrapper,
  wtype,
  wl-clipboard,
}:
let
  pythonEnv = python3Packages.python.withPackages (ps: [
    ps.sounddevice
    ps.webrtcvad
    ps.numpy
    ps.httpx
    ps.pydantic
    ps.pyyaml
  ]);
in
stdenv.mkDerivation {
  pname = "noctalia-dictation";
  version = "0.4.0";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = [
    pythonEnv
    python3Packages.pytestCheckHook
  ];

  doCheck = true;
  pytestFlagsArray = [ "tests" ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # 1. Install headless Python application
    mkdir -p $out/lib/noctalia-dictation $out/bin
    cp -r src/* $out/lib/noctalia-dictation/

    makeWrapper ${pythonEnv}/bin/python $out/bin/noctalia-dictation \
      --add-flags "$out/lib/noctalia-dictation/main.py" \
      --prefix PATH : ${
        lib.makeBinPath [
          wtype
          wl-clipboard
        ]
      }

    # 2. Install standalone Noctalia Luau plugin
    mkdir -p $out/share/noctalia-plugins/dictation
    cp -r plugin/* $out/share/noctalia-plugins/dictation/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Headless voice dictation daemon with Groq AI and Noctalia Luau widget";
    platforms = platforms.linux;
    mainProgram = "noctalia-dictation";
  };
}

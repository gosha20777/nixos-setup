{
  lib,
  stdenv,
  python3,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "limine-enrich";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
    python3
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    python3 -m unittest discover tests
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/limine-enrich $out/bin
    cp -r src/* $out/libexec/limine-enrich/

    makeWrapper ${python3}/bin/python3 $out/bin/limine-enrich \
      --set PYTHONPATH "$out/libexec/limine-enrich" \
      --add-flags "$out/libexec/limine-enrich/main.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Limine bootloader configuration enricher for NixOS";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

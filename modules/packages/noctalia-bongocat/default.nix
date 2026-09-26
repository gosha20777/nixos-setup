{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "noctalia-bongocat";
  version = "1.1.4";
  src = ./.;

  installPhase = ''
    mkdir -p $out/share/noctalia-plugins/bongocat/fonts
    cp plugin.toml $out/share/noctalia-plugins/bongocat/
    cp bongocat.luau $out/share/noctalia-plugins/bongocat/
    cp fonts/bongocat.otf $out/share/noctalia-plugins/bongocat/fonts/
  '';

  meta = with lib; {
    description = "Bongo Cat bar widget for Noctalia";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

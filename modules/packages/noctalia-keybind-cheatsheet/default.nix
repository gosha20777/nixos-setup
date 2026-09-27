{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "noctalia-keybind-cheatsheet";
  version = "0.2.7";

  # Плагин живёт в community-каталоге Noctalia; берём ровно тот ревиз,
  # что опубликован как v0.2.7 (pin, не HEAD).
  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "community-plugins";
    rev = "66cd27313bb045560dfb022785ef86f0386bdd4e";
    hash = "sha256-oPKCnGBsi1XSWD+6+9OSUBuUDbExbJhmocnvT2p4DwI=";
  };

  sourceRoot = "${finalAttrs.src.name}/keybind-cheatsheet";

  # Ставим плагин в local-namespace (каталог ~/.config/noctalia/plugins,
  # та же конвенция, что у bongocat): id должен быть local/<dir>.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/noctalia-plugins/keybind-cheatsheet
    cp -r . $out/share/noctalia-plugins/keybind-cheatsheet
    sed -i 's|^id = "kenn/keybind-cheatsheet"|id = "local/keybind-cheatsheet"|' \
      $out/share/noctalia-plugins/keybind-cheatsheet/plugin.toml
    grep -q '^id = "local/keybind-cheatsheet"' \
      $out/share/noctalia-plugins/keybind-cheatsheet/plugin.toml
    runHook postInstall
  '';

  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})

{
  lib,
  stdenv,
  plymouth,
  imagemagick,
  nixos-icons,
  python3,
  bgColor ? "141617",
  surfaceColor ? "282D30",
  fgColor ? "E1DACB",
  accentColor ? "9EC468",
}:

let
  strip = hex: lib.removePrefix "#" hex;
  cleanBg = strip bgColor;
  cleanSurface = strip surfaceColor;
  cleanFg = strip fgColor;
  cleanAccent = strip accentColor;
in
stdenv.mkDerivation {
  pname = "plymouth-theme-everforest";
  version = "1.0";

  dontUnpack = true;

  nativeBuildInputs = [
    imagemagick
    python3
  ];

  buildPhase = ''
        runHook preBuild

        themeDir="$out/share/plymouth/themes/everforest"
        mkdir -p "$themeDir"

        # Compute normalized RGB color matrix for ImageMagick tinting
        calc_matrix() {
          hex="''${1#\#}"
          python3 -c "
    r = int('$hex'[0:2], 16) / 255.0
    g = int('$hex'[2:4], 16) / 255.0
    b = int('$hex'[4:6], 16) / 255.0
    print(f'{r:.3f} 0 0  0 {g:.3f} 0  0 0 {b:.3f}')
    "
        }

        fgMatrix=$(calc_matrix "${cleanFg}")
        accentMatrix=$(calc_matrix "${cleanAccent}")

        # Copy base spinner assets
        cp -r ${plymouth}/share/plymouth/themes/spinner/* "$themeDir/"

        # Recolor spinner frames to warm fg
        for f in "$themeDir"/animation-*.png; do
          magick "$f" -colorspace sRGB -channel RGB -color-matrix "$fgMatrix" "$f.tmp"
          mv "$f.tmp" "$f"
        done

        # Recolor dialog inputs & icons to warm fg
        for f in entry.png lock.png capslock.png keyboard.png key.png; do
          if [ -f "$themeDir/$f" ]; then
            magick "$themeDir/$f" -colorspace sRGB -channel RGB -color-matrix "$fgMatrix" "$themeDir/$f.tmp"
            mv "$themeDir/$f.tmp" "$themeDir/$f"
          fi
        done

        # Recolor password bullet to accent
        if [ -f "$themeDir/bullet.png" ]; then
          magick "$themeDir/bullet.png" -colorspace sRGB -channel RGB -color-matrix "$accentMatrix" "$themeDir/bullet.tmp"
          mv "$themeDir/bullet.tmp" "$themeDir/bullet.png"
        fi

        # Create watermark (NixOS logo, 128x128) tinted with warm fg
        magick ${nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png \
          -colorspace sRGB -channel RGB -color-matrix "$fgMatrix" \
          "$themeDir/watermark.png"

        # Remove the old spinner.plymouth file
        rm -f "$themeDir/spinner.plymouth"

        # Generate everforest.plymouth configuration
        cat <<EOF > "$themeDir/everforest.plymouth"
    [Plymouth Theme]
    Name=Everforest
    Description=Everforest Warm Minimal Theme
    ModuleName=two-step

    [two-step]
    Font=JetBrainsMono Nerd Font 12
    TitleFont=JetBrainsMono Nerd Font Light 30
    ImageDir=$themeDir
    DialogHorizontalAlignment=.5
    DialogVerticalAlignment=.382
    TitleHorizontalAlignment=.5
    TitleVerticalAlignment=.382
    HorizontalAlignment=.5
    VerticalAlignment=.60
    WatermarkHorizontalAlignment=.5
    WatermarkVerticalAlignment=.42
    Transition=none
    TransitionDuration=0.0
    BackgroundStartColor=0x${cleanBg}
    BackgroundEndColor=0x${cleanBg}
    ProgressBarBackgroundColor=0x${cleanSurface}
    ProgressBarForegroundColor=0x${cleanAccent}
    DialogClearsFirmwareBackground=false
    MessageBelowAnimation=true

    [boot-up]
    UseEndAnimation=false
    UseFirmwareBackground=false

    [shutdown]
    UseEndAnimation=false
    UseFirmwareBackground=false

    [reboot]
    UseEndAnimation=false
    UseFirmwareBackground=false
    EOF

        runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    # Output was created directly in buildPhase
    runHook postInstall
  '';

  meta = with lib; {
    description = "Plymouth boot splash theme matching Everforest Warm palette";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

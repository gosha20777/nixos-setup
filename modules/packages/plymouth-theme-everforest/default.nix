{
  lib,
  stdenv,
  plymouth,
  imagemagick,
  nixos-icons,
}:

stdenv.mkDerivation {
  pname = "plymouth-theme-everforest";
  version = "1.0";

  dontUnpack = true;

  nativeBuildInputs = [ imagemagick ];

  buildPhase = ''
        runHook preBuild

        themeDir="$out/share/plymouth/themes/everforest"
        mkdir -p "$themeDir"

        # Copy base spinner assets
        cp -r ${plymouth}/share/plymouth/themes/spinner/* "$themeDir/"

        # Recolor spinner frames to Everforest warm fg (#E1DACB)
        # RGB multiplier: 225/255 = 0.882, 218/255 = 0.855, 203/255 = 0.796
        for f in "$themeDir"/animation-*.png; do
          magick "$f" -colorspace sRGB -channel RGB -color-matrix "0.882 0 0  0 0.855 0  0 0 0.796" "$f.tmp"
          mv "$f.tmp" "$f"
        done

        # Recolor dialog inputs & icons to warm fg
        for f in entry.png lock.png capslock.png keyboard.png key.png; do
          if [ -f "$themeDir/$f" ]; then
            magick "$themeDir/$f" -colorspace sRGB -channel RGB -color-matrix "0.882 0 0  0 0.855 0  0 0 0.796" "$themeDir/$f.tmp"
            mv "$themeDir/$f.tmp" "$themeDir/$f"
          fi
        done

        # Recolor password bullet to accent sage (#9EC468)
        # RGB multiplier: 158/255 = 0.620, 196/255 = 0.769, 104/255 = 0.408
        if [ -f "$themeDir/bullet.png" ]; then
          magick "$themeDir/bullet.png" -colorspace sRGB -channel RGB -color-matrix "0.620 0 0  0 0.769 0  0 0 0.408" "$themeDir/bullet.tmp"
          mv "$themeDir/bullet.tmp" "$themeDir/bullet.png"
        fi

        # Create watermark (NixOS logo, 128x128) tinted with warm fg (#E1DACB)
        magick ${nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png \
          -colorspace sRGB -channel RGB -color-matrix "0.882 0 0  0 0.855 0  0 0 0.796" \
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
    BackgroundStartColor=0x141617
    BackgroundEndColor=0x141617
    ProgressBarBackgroundColor=0x282D30
    ProgressBarForegroundColor=0x9EC468
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

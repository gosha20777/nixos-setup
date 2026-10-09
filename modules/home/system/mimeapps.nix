# Default browser. Signal's Electron shell rewrites ~/.config/mimeapps.list
# on first launch when no default is set, hijacking http/https/text/html
# for itself — so `xdg-open https://...` (e.g. `gh auth refresh`) opens
# Signal instead of a browser. home-manager replaces mimeapps.list with a
# store-path symlink, which Signal can't clobber.
{
  ...
}:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "chromium-browser.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "x-scheme-handler/about" = "chromium-browser.desktop";
      "x-scheme-handler/unknown" = "chromium-browser.desktop";
      # Claude Code's URL handler (claude-cli://...) — preserved from the
      # runtime mimeapps.list so `claude` URL launches still work.
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "inode/directory" = "nemo.desktop";
      "application/x-gnome-saved-search" = "nemo.desktop";
      # PDF documents: Evince
      "application/pdf" = "org.gnome.Evince.desktop";
      "application/x-pdf" = "org.gnome.Evince.desktop";
      "application/x-bzpdf" = "org.gnome.Evince.desktop";
      "application/x-gzpdf" = "org.gnome.Evince.desktop";
      "application/x-xzpdf" = "org.gnome.Evince.desktop";
      # Default image viewer: vipsdisp (instant tile-streaming GTK4 viewer)
      "image/jpeg" = "org.libvips.vipsdisp.desktop";
      "image/png" = "org.libvips.vipsdisp.desktop";
      "image/gif" = "org.libvips.vipsdisp.desktop";
      "image/webp" = "org.libvips.vipsdisp.desktop";
      "image/x-webp" = "org.libvips.vipsdisp.desktop";
      "image/tiff" = "org.libvips.vipsdisp.desktop";
      "image/bmp" = "org.libvips.vipsdisp.desktop";
      "image/x-bmp" = "org.libvips.vipsdisp.desktop";
      "image/heic" = "org.libvips.vipsdisp.desktop";
      "image/heif" = "org.libvips.vipsdisp.desktop";
      "image/avif" = "org.libvips.vipsdisp.desktop";
      "image/jxl" = "org.libvips.vipsdisp.desktop";
      "image/jp2" = "org.libvips.vipsdisp.desktop";
      "image/svg+xml" = "org.libvips.vipsdisp.desktop";
      # RAW camera / scanner formats
      "image/x-adobe-dng" = "org.libvips.vipsdisp.desktop";
      "image/x-canon-cr2" = "org.libvips.vipsdisp.desktop";
      "image/x-canon-cr3" = "org.libvips.vipsdisp.desktop";
      "image/x-nikon-nef" = "org.libvips.vipsdisp.desktop";
      "image/x-sony-arw" = "org.libvips.vipsdisp.desktop";
      "image/x-fuji-raf" = "org.libvips.vipsdisp.desktop";
      "image/x-panasonic-raw" = "org.libvips.vipsdisp.desktop";
      "image/x-olympus-orf" = "org.libvips.vipsdisp.desktop";
      "image/x-pentax-pef" = "org.libvips.vipsdisp.desktop";
      "image/x-sigma-x3f" = "org.libvips.vipsdisp.desktop";
      "image/x-dcraw" = "org.libvips.vipsdisp.desktop";
      # Video playback: mpv
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      # Standalone audio playback: mpv
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/mp4" = "mpv.desktop";
      "audio/m4a" = "mpv.desktop";
      "audio/x-m4a" = "mpv.desktop";
      "audio/opus" = "mpv.desktop";
    };
  };
}

# Fast, hardware-accelerated media player for Wayland/Niri.
# Handles videos (MP4, MKV, WebM, etc.) and quick audio previews from Nemo/CLI.
# Complements the MPD/rmpc stack (which manages the music library/radio).
{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = [
      # Exposes playing media to DBus/MPRIS (Noctalia bar widget & media keys)
      pkgs.mpvScripts.mpris
    ];
    config = {
      # Modern GPU rendering pipeline
      vo = "gpu-next";
      # Hardware decoding (NVDEC on NVIDIA, VA-API on Intel/AMD)
      hwdec = "auto-safe";

      # Audio output via PipeWire
      ao = "pipewire";

      # Behavior
      keep-open = "yes"; # don't abruptly close on video end
      save-position-on-quit = true; # resume where you left off
      force-window = "immediate"; # show window immediately

      # Subtitles
      sub-auto = "fuzzy"; # auto-detect matching subtitles

      # High quality screenshots (useful for papers and presentations)
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";
      screenshot-template = "mpv-%F-%P";
    };
  };
}

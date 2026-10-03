{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/Radio";
    dataDir = "${config.home.homeDirectory}/.local/share/mpd";
    network.listenAddress = "127.0.0.1";
    network.port = 6600;

    extraConfig = ''
      # Audio output via PipeWire
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }

      # FIFO output for Cava / audio visualizers
      audio_output {
        type "fifo"
        name "Visualizer Feed"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }

      max_output_buffer_size "65536"

      # Automatic library update on file changes
      auto_update "yes"
      auto_update_depth "4"
      follow_outside_symlinks "yes"
      follow_inside_symlinks "yes"
    '';
  };

  # MPRIS bridge: exposes MPD to DBus/media keys and Noctalia bar widget
  services.mpd-mpris = {
    enable = true;
  };

  # Declarative radio playlists in ~/Music/Radio/
  home.file."Music/Radio" = {
    source = ../../data/radio;
    recursive = true;
  };
}

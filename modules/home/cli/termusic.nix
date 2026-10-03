{ pkgs, ... }:
{
  home.packages = [
    pkgs.termusic
    pkgs.yt-dlp
  ];

  # Declarative radio playlists in ~/Music/Radio/
  home.file."Music/Radio" = {
    source = ../../data/termusic/radio;
    recursive = true;
  };

  # Seed default radio queue in ~/.config/termusic/playlist.log if absent or empty
  # (real writable file so termusic-server can update its playback queue without HM collisions)
  home.activation.termusicPlaylistSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      PLAYLIST_DIR="$HOME/.config/termusic"
      PLAYLIST_FILE="$PLAYLIST_DIR/playlist.log"
      ${pkgs.coreutils}/bin/mkdir -p "$PLAYLIST_DIR"

      if [ ! -s "$PLAYLIST_FILE" ]; then
        ${pkgs.coreutils}/bin/cp ${../../data/termusic/radio/00_all_stations.m3u} "$PLAYLIST_FILE"
        ${pkgs.coreutils}/bin/chmod 0644 "$PLAYLIST_FILE"
      fi
    '';
  };
}

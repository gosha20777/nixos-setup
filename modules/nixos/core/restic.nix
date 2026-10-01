{ config, lib, ... }:

let
  cfg = config.my.services.restic;
in
{
  options.my.services.restic = {
    enable = lib.mkEnableOption "restic backups to HDD";
  };

  config = lib.mkIf cfg.enable {
    # Require the secret for restic
    sops.secrets."restic/password" = { };

    services.restic.backups = {
      home = {
        repository = "/mnt/storage/backup";
        passwordFile = config.sops.secrets."restic/password".path;
        paths = [ "/home" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
        pruneOpts = [
          "--keep-daily 14"
          "--keep-weekly 8"
          "--keep-monthly 12"
        ];
      };
    };
  };
}

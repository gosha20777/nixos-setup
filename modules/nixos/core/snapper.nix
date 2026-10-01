{ config, ... }:

{
  services.snapper.configs = {
    home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ config.systemSettings.username ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
}

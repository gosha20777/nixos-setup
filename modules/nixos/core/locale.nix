{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Locale + timezone
  # America/New_York follows EST/EDT (DST-aware). en_US.UTF-8 gives
  # imperial measurement units, US paper sizes, etc.
  ############################################################
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
}

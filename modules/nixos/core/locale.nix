{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Locale + timezone
  # Timezone is wired to systemSettings.timeZone (default: Europe/Berlin).
  # en_US.UTF-8 is defaultLocale for terminal and CLI tools, while
  # supportedLocales compiles glibc support for English, Russian, and German.
  ############################################################
  time.timeZone = config.systemSettings.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];
}

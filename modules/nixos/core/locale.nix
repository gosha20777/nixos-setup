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
  # en_US.UTF-8 is defaultLocale for messages (English); LC_TIME is en_GB —
  # European conventions (day-first dates, Monday-first weeks, 24h) with
  # English weekday/month names — while LC_MONETARY is de_DE for the Euro.
  # LC_NUMERIC stays en_US (decimal point "."). supportedLocales compiles
  # glibc support for the English (US/GB), Russian, and German locales.
  ############################################################
  time.timeZone = config.systemSettings.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
  };
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];
}

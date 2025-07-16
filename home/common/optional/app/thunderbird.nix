{
  config,
  osConfig,
  lib,
  ...
}: let
  inherit (osConfig) systemOpts;
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".thunderbird"
    ];
  };
  programs.thunderbird = {
    enable = true;
    settings = {
      "privacy.donottrackheader.enabled" = true;
      "extensions.activeThemeID" = "default-theme@mozilla.org";
    };
    profiles.${config.home.username} = {
      isDefault = true;
    };
  };
}

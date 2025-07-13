{
  systemOpts,
  userOpts,
  lib,
  ...
}: {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
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
    profiles.ryan = {
      isDefault = true;
    };
  };
}

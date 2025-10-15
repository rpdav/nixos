{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    protonup
    freetype
  ];

  ## This must be imperatively set up by running "protonup". Further updates are handled by steam
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${config.home.homeDirectory}/.steam/root/compatibilitytools.d";
  };
}

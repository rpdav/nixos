{
  pkgs,
  userOpts,
  ...
}: {
  home.packages = with pkgs; [
    protonup
  ];

  ## This must be imperatively set up by running "protonup". Further updates are handled by steam
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${userOpts.username}/.steam/root/compatibilitytools.d";
  };
}

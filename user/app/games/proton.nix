{pkgs, userSettings, ...}:

{
  home.packages = with pkgs; [
    protonup
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/home/${userSettings.username}/.steam/root/compatibilitytools.d";
  };
}

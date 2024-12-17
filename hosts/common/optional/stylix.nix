{
  pkgs,
  userSettings,
  lib,
  configLib,
  ...
}: let
  themePath = configLib.relativeToRoot "themes/${userSettings.wallpaper}";

  image = 
    if builtins.pathExists "${themePath}/wallpaper.jpg"
    then "${themePath}/wallpaper.jpg"
    else "${themePath}/wallpaper.png";

  #declare customTheme var if scheme.txt exists alongside wallpaper
  customTheme =
    if builtins.pathExists "${themePath}/scheme.txt"
    then "${themePath}/scheme.txt"
      |> builtins.readFile
      |> lib.removeSuffix "\n"
    else "";

  # If scheme.txt exists in wallpaper directory, use that; otherwise use userSettings.base16scheme
  base16Scheme =
    if customTheme == ""
    then "${pkgs.base16-schemes}/share/themes/${userSettings.base16scheme}.yaml"
    else "${pkgs.base16-schemes}/share/themes/${customTheme}.yaml";

  polarity = "${themePath}/polarity.txt"
    |> builtins.readFile
    |> lib.removeSuffix "\n";

in {
  stylix = {
    enable = true;
    inherit base16Scheme;
    inherit image;
    inherit polarity;
    imageScalingMode = "center";
  };

  # Shortlist of good schemes:
  # catppuccin-mocha
  # gruvbox-material-dark-hard
  # atelier-dune
  # 3024
  # colors
  # isotope
  # tokyo-night-terminal-dark

  stylix.fonts.sizes = {
    applications = 10;
    terminal = 10;
    desktop = 10;
    popups = 10;
  };

  stylix.opacity = {
    applications = 1.0;
    terminal = 0.85;
    desktop = 1.0;
    popups = 1.0;
  };

#TODO set up fonts
#  stylix.fonts = {
#    monospace = {
#      name = userSettings.font;
#      package = userSettings.fontPkg;
#    };
#    serif = {
#      name = userSettings.font;
#      package = userSettings.fontPkg;
#    };
#    sansSerif = {
#      name = userSettings.font;
#      package = userSettings.fontPkg;
#    };
#    emoji = {
#      name = "Noto Color Emoji";
#      package = pkgs.noto-fonts-emoji-blob-bin;
#    };
#  };
}

{
  pkgs,
  userSettings,
  lib,
  configLib,
  inputs,
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
  imports = [inputs.stylix.nixosModules.stylix];

  stylix = {
    enable = true;
    inherit base16Scheme;
    inherit image;
    inherit polarity;
    imageScalingMode = "center";
  };

  #TODO add extra gtk theming?

  # Favorite schemes:
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

  stylix.cursor = {
    package = pkgs.${userSettings.cursorPkg};
    name = userSettings.cursor;
    size = 24;
  };

  #TODO should this go in userSettings? 6 vars seems a bit excessive.
  # would be nice if a single package covered multiple fonts.
  stylix.fonts = {
    monospace = {
      name = "Intel One Mono";
      package = pkgs.intel-one-mono;
    };
    serif = {
      name = "Ubuntu";
      package = pkgs.nerd-fonts.ubuntu;
    };
    sansSerif = {
      name = "Ubuntu Sans";
      package = pkgs.nerd-fonts.ubuntu-sans;
    };
    #    emoji = {
    #      name = "Noto Color Emoji";
    #      package = pkgs.noto-fonts-emoji-blob-bin;
    #    };
  };
}

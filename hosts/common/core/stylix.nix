{
  pkgs,
  config,
  lib,
  configLib,
  inputs,
  ...
}: let
  inherit (config) userOpts;
  themePath = configLib.relativeToRoot "themes/${userOpts.theme}";

  # choose appropriate wallpaper file type
  image =
    if builtins.pathExists "${themePath}/wallpaper.jpg"
    then "${themePath}/wallpaper.jpg"
    else "${themePath}/wallpaper.png";

  # extract theme name from scheme.txt
  themeName =
    "${themePath}/scheme.txt"
    |> builtins.readFile
    |> lib.removeSuffix "\n";

  # pull scheme yaml from base16-schemes
  base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";

  # pull polarity from polarity.txt
  polarity =
    "${themePath}/polarity.txt"
    |> builtins.readFile
    |> lib.removeSuffix "\n";
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    inherit base16Scheme;
    inherit image;
    inherit polarity;
    imageScalingMode = "fill";
  };

  stylix.targets = {
    console.enable = false;
  };

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
    terminal = 0.95;
    desktop = 1.0;
    popups = 1.0;
  };

  stylix.cursor = {
    package = pkgs.${userOpts.cursorPkg};
    name = userOpts.cursor;
    size = 24;
  };

  #TODO should this go in userOpts? 6 vars seems a bit excessive.
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
    emoji = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
}

{
  pkgs,
  lib,
  configLib,
  config,
  osConfig,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host fw13

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/app/browser"
      "home/common/optional/app/kitty.nix"
      "home/common/optional/config/persist.nix"
      "home/common/optional/wm/hyprland"
    ])
    # multi-system config for current user
    ./common/core

    ./common/optional/yubikey.nix
    ./common/optional/accounts.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "25.11"; # don't change without reading release notes

  # Hyprland monitor config
  monitors = [
    {
      name = "DP-12";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 0;
      y = 0;
      scaling = 1.0;
      enabled = true;
    }
    {
      name = "DP-10";
      width = 1920;
      height = 1080;
      refreshRate = 144;
      x = 1920;
      y = 0;
      scaling = 1.0;
      enabled = true;
    }
    {
      name = "eDP-1";
      width = 2880;
      height = 1920;
      refreshRate = 120;
      x = 3840;
      y = 0;
      scaling = 2.0;
      enabled = true;
    }
  ];

  gtk.iconTheme = {
    name = osConfig.stylix.fonts.emoji.name;
    package = osConfig.stylix.fonts.emoji.package;
  };
}

{
  config,
  osConfig,
  configLib,
  lib,
  ...
}: let
  inherit (osConfig) systemOpts;
in {
  ## This file contains all home-manager config unique to user ryan on host fw13nix

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/app/browser"
      "home/common/optional/app/defaultapps.nix"
      "home/common/optional/app/nextcloud.nix"
      "home/common/optional/app/kitty.nix"
      "home/common/optional/config/persist.nix"
      "home/common/optional/wm/cinnamon.nix"

      # monitor module
      "modules/hyprland/monitors.nix"
    ])
    # multi-system config for current user
    ./common/core

    ./common/optional/yubikey.nix
    ./common/optional/accounts.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "25.05"; # Please read the comment before changing.
}

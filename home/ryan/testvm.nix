{
  pkgs,
  lib,
  configLib,
  config,
  osConfig,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host testvm

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/config/persist.nix"
    ])
    # multi-system config for current user
    ./common/core
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "25.11"; # don't change without reading release notes

  gtk.iconTheme = {
    name = osConfig.stylix.fonts.emoji.name;
    package = osConfig.stylix.fonts.emoji.package;
  };

  home.packages = with pkgs; [
    parsec-bin
  ];
}

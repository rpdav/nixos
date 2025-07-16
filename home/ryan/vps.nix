{
  lib,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host vps

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/config/persist.nix"
    ])
    # multi-system config for current user
    ./common/optional/config/yubikey.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

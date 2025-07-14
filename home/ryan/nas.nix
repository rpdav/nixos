{
  pkgs,
  lib,
  systemOpts,
  userOpts,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host nas

  imports = [
    # core config
    (configLib.relativeToRoot "vars")
    ./common/core

    # optional config
    ./common/optional/app/browser
    ./common/optional/app/defaultapps.nix
    ./common/optional/app/games
    ./common/optional/app/kitty.nix
    ./common/optional/config/persist.nix
    ./common/optional/config/yubikey.nix
    ./common/optional/wm/gnome.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # don't change without reading release notes

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
}

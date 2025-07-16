{
  lib,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host nas

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/app/browser"
      "home/common/optional/app/defaultapps.nix"
      "home/common/optional/app/games"
      "home/common/optional/app/kitty.nix"
      "home/common/optional/config/persist.nix"
      "home/common/optional/wm/gnome.nix"
    ])
    # multi-system config for current user
    ./common/optional/config/yubikey.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # don't change without reading release notes

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
}

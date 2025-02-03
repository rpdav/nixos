{
  pkgs,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host vps

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    # core config
    (configLib.relativeToRoot "vars")
    ./common/core

    # optional config
    ./common/optional/config/persist.nix
    ./common/optional/config/yubikey.nix
  ];

  home.packages = with pkgs; [
  ];

}

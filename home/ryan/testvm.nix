{
  pkgs,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host fw13nix

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    # core config
    (configLib.relativeToRoot "vars")
    #./common/core

    # optional config
    #./common/optional/app/accounts.nix
    #./common/optional/app/browser
    #./common/optional/app/defaultapps.nix
    #./common/optional/app/games
    #./common/optional/app/kitty.nix
    #./common/optional/app/thunderbird.nix
    #./common/optional/app/web-apps
    #./common/optional/config/persist.nix
    #./common/optional/config/yubikey.nix
    #./common/optional/wm/gnome.nix
  ];

  home.packages = with pkgs; [
  ];

}

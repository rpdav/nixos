{
  pkgs,
  configLib,
  systemOpts,
  userOpts,
  lib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host fw13nix

  imports = [
    # core config
    (configLib.relativeToRoot "vars")
    ./common/core

    # optional config
    #./common/optional/app/accounts.nix
    #./common/optional/app/browser
    #./common/optional/app/defaultapps.nix
    #./common/optional/app/games
    #./common/optional/app/kitty.nix
    #./common/optional/app/thunderbird.nix
    #./common/optional/app/web-apps
    ./common/optional/config/persist.nix
    ./common/optional/config/yubikey.nix
    ./common/optional/wm/cinnamon.nix

    # monitor module
    (configLib.relativeToRoot "modules/hyprland/monitors.nix")
  ];

  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
    ];
    files = [
      ".config/bluedevelglobalrc" # bluetooth
    ];
  };

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    librewolf
    brave
    onlyoffice-bin
    kdePackages.ghostwriter
    audacity

    # terminals
    kitty

    # scripts
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # client starts to early and fails; this delays it a bit
  systemd.user.services.nextcloud-client = {
    Unit = {
      After = pkgs.lib.mkForce "graphical-session.target";
    };
  };
}

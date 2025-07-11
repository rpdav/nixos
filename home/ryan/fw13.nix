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
    ./common/optional/app/accounts.nix
    ./common/optional/app/browser
    ./common/optional/app/defaultapps.nix
    ./common/optional/app/games
    ./common/optional/app/kitty.nix
    ./common/optional/app/thunderbird.nix
    ./common/optional/app/web-apps
    ./common/optional/config/persist.nix
    ./common/optional/config/yubikey.nix
    ./common/optional/wm/hyprland

    # monitor module
    (configLib.relativeToRoot "modules/hyprland/monitors.nix")
  ];

  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".sword"
      ".config/BraveSoftware"
      ".config/GIMP"
      ".config/Nextcloud"
      ".config/onlyoffice"
      ".config/remmina"
    ];
    files = [
      ".config/ghostwriterrc"
      ".config/bluedevelglobalrc" # bluetooth
    ];
  };

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

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

  home.packages = with pkgs; [
    thunderbird
    librewolf
    brave
    tor-browser
    remmina
    onlyoffice-bin
    kdePackages.ghostwriter
    bibletime
    audacity
    gimp
    jellyfin-media-player

    # terminals
    kitty
    alacritty

    # games
    kdePackages.knights
    kdePackages.killbots
    kdePackages.kgoldrunner
    kdePackages.kmines
    kdePackages.kpat

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

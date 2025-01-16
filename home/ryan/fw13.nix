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
    ./common/optional/app/alacritty.nix
    ./common/optional/app/kitty.nix
    ./common/optional/app/thunderbird.nix
    ./common/optional/app/web-apps
    ./common/optional/config/persist.nix
    ./common/optional/config/yubikey.nix
    ./common/optional/wm/gnome.nix
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

  home.packages = with pkgs; [
    thunderbird
    librewolf
    brave
    tor-browser
    remmina
    onlyoffice-bin
    ghostwriter
    bibletime
    audacity
    gimp

    # terminals
    kitty
    alacritty
    yakuake

    # games
    knights
    killbots
    kdePackages.kgoldrunner
    kmines
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

{
  pkgs,
  lib,
  systemOpts,
  userOpts,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host vps

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

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

  # Disable sleep in gnome

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };
}

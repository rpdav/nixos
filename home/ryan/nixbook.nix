{ lib, config, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
## This file contains all home-manager config unique to user ryan on host nixbook
#TODO move common config (for ryan on other hosts) to common/{core,optional}

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ../../vars

    ./common/core

    ./common/optional/app/browser
    ./common/optional/app/defaultapps.nix
    ./common/optional/app/games
    ./common/optional/app/kitty.nix
    ./common/optional/app/thunderbird.nix
    ./common/optional/config/persist.nix
    ./common/optional/wm/gnome.nix
  ];

  home.packages = 
    (with pkgs; [
    #protonmail-bridge-gui
    thunderbird
    librewolf
    brave
    tor-browser
    remmina
    onlyoffice-bin
    ghostwriter
    bibletime
    xiphos
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
    (import ./common/optional/scripts/wgdown.nix { inherit pkgs; })
    (import ./common/optional/scripts/wgup.nix { inherit pkgs; })
  ])

  ++

  (with pkgs-stable; [
    protonmail-bridge-gui #bridge is throwing QML component error
  ]);

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # for using yubikey for ssh and sudo auth
  services.yubikey-touch-detector.enable = true;

#TODO should this be made generic and put somewhere else? Maybe sops.nix?
  sops.secrets."ryan/u2f_keys".path = "/home/ryan/.config/Yubico/u2f_keys";

}


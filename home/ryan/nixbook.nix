{ lib, config, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
## This file contains all home-manager config unique to user ryan on host nixbook
#TODO move common config (for ryan on other hosts) to common/{core,optional}

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports =
    [  ../../variables.nix
      ./common/app/bash.nix
      ./common/app/browser
      ./common/app/defaultapps.nix
      ./common/app/games
      ./common/app/git.nix
      ./common/app/kitty.nix
      ./common/app/thunderbird.nix
      ./common/app/vim.nix
      ./common/config/persist.nix
      ./common/config/ssh.nix
      ./common/sops.nix
      ./common/wm/kde.nix
    ];

  home.packages = with pkgs; [
    protonmail-bridge-gui
    thunderbird
    librewolf
    brave
    tor-browser
    tree
    remmina
    onlyoffice-bin
    ghostwriter
    bibletime
    xiphos
    audacity
    gimp
    fastfetch
    lazygit
    just

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
    # TODO these should be moved to home dir, not hosts
    (import ./common/scripts/fs-diff.nix { inherit pkgs; })
    (import ./common/scripts/wgdown.nix { inherit pkgs; })
    (import ./common/scripts/wgup.nix { inherit pkgs; })
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

}


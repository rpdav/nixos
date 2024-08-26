{ lib, config, pkgs, pkgs-stable, systemSettings, userSettings, ... }:

{
  home.username = "${userSettings.username}";
  home.homeDirectory = "/home/${userSettings.username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports =
    [  ../../variables.nix
      ../../modules/home-manager/app/bash.nix
      ../../modules/home-manager/app/browser
      ../../modules/home-manager/app/defaultapps.nix
      ../../modules/home-manager/app/games
      ../../modules/home-manager/app/git.nix
      ../../modules/home-manager/app/kitty.nix
      ../../modules/home-manager/app/thunderbird.nix
      ../../modules/home-manager/app/vim.nix
      ../../modules/home-manager/config/persist.nix
      ../../modules/home-manager/config/ssh.nix
      ../../modules/home-manager/sops.nix
      ../../modules/home-manager/wm/kde.nix
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
    (import ../../modules/nixos/scripts/fs-diff.nix { inherit pkgs; })
    (import ../../modules/nixos/scripts/wgdown.nix { inherit pkgs; })
    (import ../../modules/nixos/scripts/wgup.nix { inherit pkgs; })
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

}


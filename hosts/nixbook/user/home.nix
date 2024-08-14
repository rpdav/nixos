{ lib, config, pkgs, pkgs-stable, impermanence, secrets, systemSettings, userSettings, ... }:

#let
#  config.systemVars.asdf = lib.mkOverride "override";
#in
{
  home.username = "${userSettings.username}";
  home.homeDirectory = "/home/${userSettings.username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports =
    [ ./app/browser/firefox.nix
      ./app/browser/chromium.nix
      ./app/browser/webapps.nix
      ./app/email/thunderbird.nix
      ./app/git/git.nix
      ./app/editor/vim.nix
      ./app/shell/bash.nix
      ./app/games/games.nix
      ./app/games/proton.nix
      ./app/terminal/kitty.nix
      ./config/ssh.nix
      ./persistence/persist.nix
      ./wm/kde/kde.nix
      ../../../variables.nix
    ];

  home.packages = with pkgs; [
    protonmail-bridge-gui
    thunderbird
    #firefox #disabled due to collision - not sure from what
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
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

}


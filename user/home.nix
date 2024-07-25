{ config, pkgs, impermanence, secrets, systemSettings, userSettings, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in {
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

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
      ./config/ssh.nix
      (./wm +("/"+userSettings.wm+"/"+userSettings.wm)+".nix")
    ];

  home.packages = with pkgs; [
    protonmail-bridge-gui
    thunderbird
    firefox
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

## can't get this to talk to any calendar apps. not sure if it's even authenticating with the server.
  accounts.calendar = {
    basePath = ".calendar";
    accounts.nextcloud = {
      primary = true;
      name = "nextcloud";
      remote = {
        type = "caldav";
        url = "https://cloud.***REMOVED***/remote.php/dav/";
        userName = "ryan";
      };
    };
  };

}


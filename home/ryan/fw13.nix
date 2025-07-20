{
  pkgs,
  lib,
  configLib,
  config,
  osConfig,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host fw13

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/app/browser"
      "home/common/optional/app/defaultapps.nix"
      "home/common/optional/app/games"
      "home/common/optional/app/nextcloud.nix"
      "home/common/optional/app/kitty.nix"
      "home/common/optional/app/thunderbird.nix"
      "home/common/optional/app/web-apps"
      "home/common/optional/config/persist.nix"
      "home/common/optional/wm/hyprland"
      "home/common/optional/config/backup.nix"

      # monitor module
      "modules/hyprland/monitors.nix"
    ])
    # multi-system config for current user
    ./common/core

    ./common/optional/yubikey.nix
    ./common/optional/accounts.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.05"; # don't change without reading release notes

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
  backupOpts = {
    patterns = [
      "R /persist/home/ryan/Documents"
      "- /persist/home/ryan/Documents/medical"
      "- **/*.tar" #omit tar files
      #"+ /persist/home/ryan/Documents" #back up everything else

      #"- **/.git" #can be restored from repos
      #"- **/.Trash*" #automatically made by gui deletions
      #"- **/.local/share/libvirt" #vdisks made mostly for testing
      #"- */home/*/Downloads/" #big files
      #"- */home/ryan/Nextcloud" #already on server
      #"- */home/*/.thunderbird/*/ImapMail" #email
      #"- */home/*/.local/share/Steam" #lots of small files and big games
      #"- */home/*/.local/share/lutris" #lots of small files and big games
      #"- */home/*/.local/share/protonmail" #email
    ];
    sourceDirectories = ["/persist/home/ryan/Documents"];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

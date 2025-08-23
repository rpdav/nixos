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
      "home/common/optional/app/crush.nix"
      "home/common/optional/app/defaultapps.nix"
      "home/common/optional/app/games"
      "home/common/optional/app/nextcloud.nix"
      "home/common/optional/app/kitty.nix"
      "home/common/optional/app/thunderbird.nix"
      "home/common/optional/app/web-apps"
      "home/common/optional/config/persist.nix"
      "home/common/optional/wm/hyprland"

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
      "- **/.git" #can be restored from repos
      "- **/.Trash*" #automatically made by gui deletions
      "- **/.local/share/libvirt" #vdisks made mostly for testing
      "- /persist/home/ryan/Downloads/" #big files
      "- /persist/home/ryan/Nextcloud" #already on server
      "- /persist/home/ryan/.thunderbird/*/ImapMail" #email
      "- /persist/home/ryan/.local/share/Steam" #lots of small files and big games
      "- /persist/home/ryan/.local/share/lutris" #lots of small files and big games
      "- /persist/home/ryan/.local/share/protonmail" #email
      "+ /persist/home/ryan" #back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
  gtk.iconTheme = {
    name = osConfig.stylix.fonts.emoji.name;
    package = osConfig.stylix.fonts.emoji.package;
  };
}

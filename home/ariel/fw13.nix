{
  pkgs,
  lib,
  configLib,
  config,
  osConfig,
  ...
}: {
  ## This file contains all home-manager config unique to user ariel on host fw13

  imports = map configLib.relativeToRoot [
    # core config
    "vars"
    "home/common/core"

    # optional config
    "home/common/optional/app/browser" # is A good with this config?
    "home/common/optional/app/defaultapps.nix"
    "home/common/optional/app/nextcloud.nix"
    "home/common/optional/app/kitty.nix"
    "home/common/optional/app/web-apps"
    "home/common/optional/config/persist.nix"
    "home/common/optional/wm/hyprland"

    # monitor module
    "modules/hyprland/monitors.nix"
  ];

  home.username = "ariel";
  home.homeDirectory = "/home/ariel";

  home.stateVersion = "24.05"; # don't change without reading release notes

  backupOpts = {
    patterns = [
      "- **/.Trash*" #automatically made by gui deletions
      "- /persist/home/ariel/Downloads/" #big files
      "- /persist/home/ariel/Nextcloud" #already on server
      "+ /persist/home/ariel" #back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

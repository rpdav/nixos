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
    "home/common/optional/config/persist.nix" # user persistence isn't used but this module needs loaded to process conditionals in shared modules
    "home/common/optional/wm/hyprland"
  ];

  home.username = "ariel";
  home.homeDirectory = "/home/ariel";

  home.stateVersion = "25.05"; # don't change without reading release notes

  userOpts = {
    impermanent = false;
  };

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

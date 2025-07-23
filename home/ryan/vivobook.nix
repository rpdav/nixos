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
      "home/common/optional/app/kitty.nix"
      "home/common/optional/app/web-apps"
      "home/common/optional/config/persist.nix"
      "home/common/optional/wm/cinnamon.nix"
    ])
    # multi-system config for current user
    ./common/core
    ./common/optional/yubikey.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "25.05"; # don't change without reading release notes

  backupOpts = {
    patterns = [
      "- **/.git" #can be restored from repos
      "- **/.Trash*" #automatically made by gui deletions
      "- /persist/home/ryan/Downloads/" #big files
      "- /persist/home/ryan/Nextcloud" #already on server
      "+ /persist/home/ryan" #back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

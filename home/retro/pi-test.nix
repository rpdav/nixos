{configLib, ...}: {
  ## This file contains all home-manager config unique to user retro on host pi-test
  ## This is a service account only for accessing the retroarch ui

  imports = map configLib.relativeToRoot [
    # core config
    "home/common/core"

    # optional config
    "home/common/optional/wm/retroarch.nix"
  ];

  home.username = "retro";
  home.homeDirectory = "/home/retro";

  home.stateVersion = "24.11"; # don't change without reading release notes

  userOpts = {
    impermanent = false;
  };

  backupOpts = {
    patterns = [
      "- **/.Trash*" #automatically made by gui deletions
      "- /persist/home/retro/Downloads/" #big files
      "+ /persist/home/retro" #back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

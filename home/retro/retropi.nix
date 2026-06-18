{...}: {
  flake.homeModules."retro@retropi" = {configLib, ...}: {
    ## This file contains all home-manager config unique to user retro on host retropi
    ## This is a service account only for accessing the retroarch ui

    imports = map configLib.relativeToRoot [
      # core config
      "home/common/core"

      # optional config
      "home/common/optional/wm/retroarch.nix"
    ];

    home.username = "retro";
    home.homeDirectory = "/home/retro";

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
  };
}

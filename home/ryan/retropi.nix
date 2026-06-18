{...}: {
  flake.homeModules."ryan@retropi" = {
    lib,
    configLib,
    ...
  }: {
    ## This file contains all home-manager config unique to user ryan on host retropi

    imports = lib.flatten [
      (map configLib.relativeToRoot [
        # core config
        "home/common/core"

        # optional config
      ])
      # multi-system config for current user
      ./common/core
      ./common/optional/yubikey.nix
    ];

    userOpts = {
      impermanent = false;
    };

    home.username = "ryan";
    home.homeDirectory = "/home/ryan";

    backupOpts = {
      patterns = [
        "- **/.git" #can be restored from repos
        "+ /persist/home/ryan" #back up everything else
      ];
      localRepo = "ssh://borg@borg:2222/backup";
      #remoteRepo = "";
    };
  };
}

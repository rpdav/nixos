{
  lib,
  configLib,
  ...
}: {
  ## This file contains all home-manager config unique to user ryan on host vps

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/config/persist.nix"
    ])
    # multi-system config for current user
    ./common/core

    ./common/optional/yubikey.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  backupOpts = {
    patterns = [
      "- **/.git" #can be restored from repos
      "+ /persist/home/ryan" #back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

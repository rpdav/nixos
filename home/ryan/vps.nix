{...}: {
  flake.homeModules."ryan@vps" = {configLib, ...}: {
    ## This file contains all home-manager config unique to user ryan on host vps

    imports = map configLib.relativeToRoot [
      # core config
      "home/common/core"

      # optional config
      "home/common/optional/yubikey.nix"
    ];

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

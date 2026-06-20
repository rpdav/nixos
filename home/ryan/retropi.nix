{self, ...}: {
  flake.homeModules."ryan@retropi" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host retropi

    imports = [
      self.homeModules.core
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

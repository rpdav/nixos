{self, ...}: {
  flake.homeModules."retro@retropi" = {...}: {
    ## This file contains all home-manager config unique to user retro on host retropi
    ## This is a service account only for accessing the retroarch ui

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      user-retro

      # optional config
      backup

      # wm
      retroarch
    ];

    userOpts = {
      impermanent = false;
    };

    backupOpts = {
      patterns = [
      ];
      localRepo = "ssh://borg@borg:2222/backup";
      #remoteRepo = "";
    };
  };
}

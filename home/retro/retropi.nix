{self, ...}: {
  flake.homeModules."retro@retropi" = {...}: {
    ## This file contains all home-manager config unique to user retro on host retropi
    ## This is a service account only for accessing the retroarch ui

    imports = [
      # core config
      self.homeModules.core

      # base user config
      self.homeModules.user-retro

      # wm
      self.homeModules.retroarch
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

{self, ...}: {
  flake.homeModules."ryan@retropi" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host retropi

    imports = [
      # core config
      self.homeModulse.core

      # base user config
      self.homeModules.user-ryan
    ];

    userOpts = {
      impermanent = false;
    };
  };
}

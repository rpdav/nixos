{self, ...}: {
  flake.homeModules."ryan@retropi" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host retropi

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      user-ryan
    ];

    userOpts = {
      impermanent = false;
    };
  };
}

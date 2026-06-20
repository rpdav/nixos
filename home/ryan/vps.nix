{self, ...}: {
  flake.homeModules."ryan@vps" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host vps

    imports = [
      # core config
      self.homeModules.core

      # base user config
      self.homeModules.ryan
    ];
  };
}

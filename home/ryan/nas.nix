{self, ...}: {
  flake.homeModules."ryan@nas" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host nas

    imports = [
      # core config
      self.homeModules.core

      # base user config
      self.homeModules.ryan
    ];
  };
}

{self, ...}: {
  flake.homeModules."ryan@nas" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host nas

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      user-ryan
    ];
  };
}

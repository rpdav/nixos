{self, ...}: {
  flake.homeModules."ryan@vps" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host vps

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      user-ryan
    ];
  };
}

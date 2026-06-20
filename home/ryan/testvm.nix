{self, ...}: {
  flake.homeModules."ryan@testvm" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host fw13

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      ryan

      # apps
      firefox
      chromium
      kitty

      # wm
      hyprland
      hypridle
      hyprlock
      waybar
      wlogout
    ];
  };
}

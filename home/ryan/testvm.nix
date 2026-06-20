{self, ...}: {
  flake.homeModules."ryan@testvm" = {osConfig, ...}: {
    ## This file contains all home-manager config unique to user ryan on host fw13

    imports = with self.homeModules; [
      # core config
      core

      # optional config
      yubikeyConfig

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

    home.username = "ryan";
    home.homeDirectory = "/home/ryan";

    # Hyprland monitor config
    monitors = [
      {
        name = "DP-12";
        width = 1920;
        height = 1080;
        refreshRate = 60;
        x = 0;
        y = 0;
        scaling = 1.0;
        enabled = true;
      }
      {
        name = "DP-10";
        width = 1920;
        height = 1080;
        refreshRate = 144;
        x = 1920;
        y = 0;
        scaling = 1.0;
        enabled = true;
      }
      {
        name = "eDP-1";
        width = 2880;
        height = 1920;
        refreshRate = 120;
        x = 3840;
        y = 0;
        scaling = 2.0;
        enabled = true;
      }
    ];

    gtk.iconTheme = {
      name = osConfig.stylix.fonts.emoji.name;
      package = osConfig.stylix.fonts.emoji.package;
    };
  };
}

{ config, pkgs, userSettings, ... }:

{

  home.packages = with pkgs; [
    aha
    clinfo
    pciutils
    wayland-utils
    #libsForQt5.polonium
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      wallpaper = "/persist/home/${userSettings.username}/Documents/wallpaper.png";
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "Breeze_Light";
        size = 24;
      };
      lookAndFeel = "org.kde.default.desktop"; # this is "Plasma Style" in settings
      iconTheme = "breeze-dark"; # breeze, breeze-dark, or oxygen
      soundTheme = "ocean";

      ## not recommended to set splashScreen or windowDecorations along with lookAndFeel
#      splashScreen = { 
#        engine = "";
#        theme = "breeze";
#      };
#      windowDecorations = { 
#        library = "org.kde.breeze";
#        theme = "Breeze";
#      };

    };

    panels = [
      {
        location = "top";
        hiding = "none";
        height = 40;
        widgets = [
          {
            name = "org.kde.plasma.kickerdash";
          }
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                fill = false;
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:${pkgs.firefox}"
                ];
              };
            };
          }
          {
            name = "org.kde.plasma.panelspacer";
          }
          {
            name = "org.kde.plasma.pager";
          }
          {
            name = "org.kde.plasma.panelspacer";
          }
          {
            systemTray.items = {
              hidden = [
                "org.kde.plasma.printmanager"
                "kded6" #kde browser integration
                "org.kde.plasma.keyboardlayout"
              ];
              shown = [
                "org.kde.plasma.volume"
                "org.kde.plasma.brightness"
                "org.kde.plasma.battery"
              ];
            };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                use24hFormat = true;
              };
            };
          }
        ];
      }
    ];

    shortcuts = {

    };

    configFile = {
      "kcminputrc"."Libinput/1267/12529/ELAN1206:00 04F3:30F1 Touchpad"."NaturalScroll" = true;
    };

  };

}

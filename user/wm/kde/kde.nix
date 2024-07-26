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

    shortcuts = {

    };

    configFile = {
      "kcminputrc"."Libinput/1267/12529/ELAN1206:00 04F3:30F1 Touchpad"."NaturalScroll" = true;
    };

  };

}

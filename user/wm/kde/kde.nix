{ config, pkgs, ... }:

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
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "Breeze";
        size = 24;
      };
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Breeze_Dark";
    };

    shortcuts = {

    };

    configFile = {
      "kcminputrc"."Libinput/1267/12529/ELAN1206:00 04F3:30F1 Touchpad"."NaturalScroll" = true;
    };

  };

}

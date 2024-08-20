{ pkgs, userSettings, ... }:

{

  stylix.enable = true;

#  stylix.image = ../../themes/rocket/wallpaper.png;

  stylix.image = ../../themes/${userSettings.theme}/wallpaper.png;
  
}

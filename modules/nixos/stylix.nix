{ pkgs, userSettings, ... }:

{

  stylix.enable = true;
  stylix.targets.grub.enable = false;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/3024.yaml";
  stylix.image = ../../themes/${userSettings.theme}/wallpaper.png;

  stylix.fonts.sizes = {
    applications = 10;
    terminal = 10;
    desktop = 10;
    popups = 10;
  };

  stylix.opacity = {
    applications = 1.0;
    terminal = 0.85;
    desktop = 1.0;
    popups = 1.0;
  };
}

{
  pkgs,
  userSettings,
  configLib,
  ...
}: {
  stylix = {
    enable = true;
    targets.grub.enable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${userSettings.base16scheme}.yaml";
    image = configLib.relativeToRoot "themes/${userSettings.wallpaper}/${userSettings.wallpaper}.jpg";
    imageScalingMode = "center";
#    polarity = "light";
  };

  # Shortlist of themes:
  # catppuccin-mocha
  # gruvbox-material-dark-hard
  # atelier-dune
  # 3024
  # colors
  # isotope
  # tokyo-night-terminal-dark

  #shortlist of wallpapers
  # ascii-cat
  # pages
  # squares
  # triangles

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

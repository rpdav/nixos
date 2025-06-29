{
  config,
  pkgs,
  lib,
  ...
}: {
  # Temporary config
  home.packages = with pkgs; [
    hypridle
  ];

  home.file.".config/hypr/hypridle.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/ryan/nixos/home/ryan/common/optional/wm/hyprland/hypridle.conf";

  #  programs.hypridle = {
  #    enable = true;
  #    settings = {
  #    };
  #  };
}

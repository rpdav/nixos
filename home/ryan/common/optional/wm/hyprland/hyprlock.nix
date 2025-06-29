{
  config,
  pkgs,
  ...
}: {
  # Temporary config
  home.packages = with pkgs; [
    hyprlock
  ];

  home.file.".config/hypr/hyprlock.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/ryan/nixos/home/ryan/common/optional/wm/hyprland/hyprlock.conf";

  #  programs.hyprlock = {
  #    enable = true;
  #    settings = {
  #    };
  #  };
}

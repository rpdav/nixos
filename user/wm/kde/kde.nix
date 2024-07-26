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

  };

}

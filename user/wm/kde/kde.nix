{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    aha
    clinfo
    pciutils
    wayland-utils
  ];

}

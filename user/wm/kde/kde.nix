{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    aha
    lspci
    clinfo
    wayland-info
  ];

}

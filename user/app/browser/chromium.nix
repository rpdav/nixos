{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    chromium
  ];

  programs.chromium = {
    enable = true;
  };

}

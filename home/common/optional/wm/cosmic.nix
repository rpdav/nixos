{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (osConfig) systemOpts;
in {
  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/cosmic"
    ];
  };
  home.packages = with pkgs; [
    quick-webapps
  ];
}

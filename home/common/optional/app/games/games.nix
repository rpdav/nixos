{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  inherit (osConfig) systemOpts;
  # define cores for retroarch
  retroarchWithCores = pkgs.retroarch.withCores (cores:
    with cores; [
      snes9x
      vba-m
      melonds
      dolphin
    ]);
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/Moonlight Game Streaming Project"
      ".config/unity3d"
      ".config/retroarch"
    ];
  };
  home.packages = [
    retroarchWithCores
    pkgs.moonlight-qt
  ];
}

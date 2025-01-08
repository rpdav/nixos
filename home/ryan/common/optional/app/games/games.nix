{
  pkgs,
  systemOpts,
  userOpts,
  lib,
  ...
}: let
  retroarchWithCores = pkgs.retroarch.withCores (cores:
    with cores; [
      snes9x
      vba-m
      melonds
    ]);
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".steam"
      ".config/Moonlight Game Streaming Project"
      ".config/unity3d"
    ];
  };
  home.packages = [
    retroarchWithCores
    pkgs.moonlight-qt
  ];
}

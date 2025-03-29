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
      dolphin
    ]);
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      #".steam" #normal persistence causes issues. this is mostly symlinks to .local/share/Steam; will try not persisting
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

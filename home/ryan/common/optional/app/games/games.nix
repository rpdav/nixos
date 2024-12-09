{pkgs, ...}: let
  retroarchWithCores = pkgs.retroarch.withCores (cores:
    with cores; [
      snes9x
      vba-m
      melonds
    ]);
in {
  home.packages = [
    retroarchWithCores
    pkgs.moonlight-qt
  ];
}

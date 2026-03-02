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
  home.persistence."${systemOpts.persistVol}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/Moonlight Game Streaming Project"
      ".config/unity3d"
      ".config/retroarch"
      ".config/Beyond-All-Reason"
    ];
  };
  home.packages = [
    retroarchWithCores
    pkgs.moonlight-qt
    pkgs.beyond-all-reason
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10" # insecure dependency for retroarch
  ];
}

{...}: {
  flake.nixosModules.games = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
    };

    environment.systemPackages = with pkgs; [
      lutris
      mangohud
    ];

    programs.gamemode.enable = true;
  };
  flake.homeModules.games = {
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
      pkgs.protonup-ng
      pkgs.freetype
    ];

    ## This must be imperatively set up by running "protonup". Further updates are handled by steam
    home.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${config.home.homeDirectory}/.steam/root/compatibilitytools.d";
    };
  };
}

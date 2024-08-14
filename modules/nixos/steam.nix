{ pkgs-stable, ... }:

{

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  environment.systemPackages = with pkgs-stable; [
    lutris
    mangohud
  ];

  programs.gamemode.enable = true;

}

{pkgs, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lutris
    mangohud
  ];

  programs.gamemode.enable = true;
}

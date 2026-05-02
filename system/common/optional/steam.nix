{pkgs, ...}: {
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
}

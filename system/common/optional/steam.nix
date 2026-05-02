{pkgs, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    protontricks.enable = true;
  };

  # LDAP test failure (dep of lutris) causing build failures.
  # Skipping tests while upstream sorts it out, revert once
  # Hydra consistently builds openldap green.
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    lutris
    mangohud
  ];

  programs.gamemode.enable = true;
}

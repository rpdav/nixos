{...}: {
  flake.nixosModules.niri = {
    lib,
    pkgs,
    ...
  }: {
    # Override hyprland auto-login while testing niri
    services.displayManager.autoLogin.enable = lib.mkForce false;

    programs.niri.enable = true;

    # temporary simple packages while testing out imperative niri.kdl
    environment.systemPackages = with pkgs; [
      brightnessctl
      playerctl
      swayosd
      networkmanagerapplet
      swaylock
      noctalia-shell
      swayidle
    ];
  };
}

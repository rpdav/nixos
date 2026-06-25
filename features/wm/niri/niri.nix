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
  flake.homeModules.niri = {pkgs, ...}: {
    programs.swaylock.enable = true;
    services.swayidle.enable = true;
    services.polkit-gnome.enable = true;
    home.packages = with pkgs; [
      swaybg # wallpaper
    ];
  };
}

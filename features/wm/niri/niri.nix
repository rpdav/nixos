{...}: {
  flake.nixosModules.niri = {lib, ...}: {
    # Override hyprland auto-login while testing niri
    services.displayManager.autoLogin.enable = lib.mkForce false;

    programs.niri.enable = true;
  };
}

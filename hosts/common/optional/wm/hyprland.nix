{
  inputs,
  pkgs,
  userOpts,
  ...
}: {
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  environment.systemPackages = with pkgs; [
    font-awesome
  ];

  #needed for waybar
  users.users.${userOpts.username} = {
    extraGroups = ["input"];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
}

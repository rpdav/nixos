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

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  environment.systemPackages = with pkgs; [
    font-awesome
  ];

  users.users.${userOpts.username} = {
    extraGroups = ["input"];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
}

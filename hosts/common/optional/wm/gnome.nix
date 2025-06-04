{pkgs, ...}: {
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome.enable = true;

  # Get rid of welcome screen for impermanent systems
  environment.gnome.excludePackages = [
    pkgs.gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
}

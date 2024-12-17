{pkgs, ...}: {
  services.xserver = {
    #xserver is legacy - this supports both xserver and wayland
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };

  # Get rid of welcome screen for impermanent systems
  environment.gnome.excludePackages = [
    pkgs.gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
}

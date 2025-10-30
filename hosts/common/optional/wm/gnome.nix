{pkgs, ...}: {
  ### Default gnome config
  services.displayManager.gdm = {
    enable = true;
    wayland = false;
    autoSuspend = false;
  };
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

  # Get rid of welcome screen for impermanent systems
  environment.gnome.excludePackages = [
    pkgs.gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  ### Cosmic specialization
  #  specialisation.cosmic.configuration = {
  #    inputs,
  #    lib,
  #    ...
  #  }: {
  #    # Enable cosmic
  #    services.desktopManager.cosmic.enable = true;
  #    services.displayManager.cosmic-greeter.enable = true;
  #
  #    services.flatpak.enable = true;
  #
  #    # Disable gnome
  #    services.displayManager.gdm.enable = lib.mkForce false;
  #    services.desktopManager.gnome.enable = lib.mkForce false;
  #  };
}

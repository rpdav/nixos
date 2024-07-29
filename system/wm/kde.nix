{ config, ... }:


{

  #services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

## Disable packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    firefox # already in home.nix
  ];

}

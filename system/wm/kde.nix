{ config, stablePlasma, ... }:


{

  disabledModules = [
    "services/desktop-managers/plasma6.nix"
  ];

  imports = [ stablePlasma  ];

#  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

## Disable packages if desired
#  environment.plasma6.excludePackages = with pkgs.kdePackages; [
#    plasma-browser-integration
#    konsole
#    oxygen
#  ];

}

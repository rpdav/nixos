{ config, ... }:

disabledModules = [
<nixos/nixos/modules/services/desktop-managers/plasma6.nix>
];
imports = [
<nixos-stable/nixos/modules/services/desktop-managers/plasma6.nix>
];

{
#  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

## Disable packegs if desired
#  environment.plasma6.excludePackages = with pkgs.kdePackages; [
#    plasma-browser-integration
#    konsole
#    oxygen
#  ];

}

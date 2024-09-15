{ config, pkgs, ... }:

{
## Gnome X11
  services.xserver = {
	enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

}

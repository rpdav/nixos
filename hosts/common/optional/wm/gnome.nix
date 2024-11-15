{ config, pkgs, ... }:

{

  services.xserver = { #xserver is legacy - this supports both xserver and wayland
	enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };

}

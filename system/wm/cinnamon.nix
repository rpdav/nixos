{ config, pkgs, ... }:

{
  services.xserver = {
	enable = true;
	displayManager.lightdm.enable = true;
	desktopManager.cinnamon.enable = true;
  };
}
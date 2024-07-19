{ config, pkgs, ... }:

{
  
  services.displayManager.defaultSession = "cinnamon";
  
  services.xserver = {
	enable = true;
	displayManager.sddm.enable = true;
	desktopManager.cinnamon.enable = true;
  };
}

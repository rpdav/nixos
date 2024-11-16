{ config, pkgs, userSettings, ... }:

{

  services.xserver = { #xserver is legacy - this supports both xserver and wayland
	enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
      settings = {
        daemon = {
          TimedLoginEnable = true;
          TimedLogin = userSettings.username;
          TimedLoginDelay = 2;
        };
      };
    };
    desktopManager.gnome.enable = true;
  };

}

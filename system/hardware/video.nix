{ config, pkgs-unstable, userSettings, ... }:

{
  hardware.opengl = {
    enable = true;
    enable32bit = true;
    };

  services.xserver.videoDrivers = ["nvidia"];

#  hardware.nvidia.modesetting.enable = true; #probably only needed for wayland



}

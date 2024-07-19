{ config, pkgs, userSettings, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32bit = true;
    };

  services.xserver.videoDrivers = ["nvidia"];

#  hardware.nvidia.modesetting.enable = true; #probably only needed for wayland



}

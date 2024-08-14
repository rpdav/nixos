{ pkgs, lib, config, ... }:

{
## Enable Nvidia hardware acceleration
  hardware.graphics = {
    enable = true;
    };
  services.xserver.videoDrivers = [ "nvidia" ];

## Add Nvidia kernel module
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  # Disable iGPU
#  boot.kernelParams = [ "module_blacklist=amdgpu" ];

## General Nvidia config - taken from https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # use closed-source driver
    nvidiaSettings = true; # accessible via `nvidia-settings`.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  }; 

	hardware.nvidia.prime = {
		# Integrated
    amdgpuBusId = "PCI:04:00:0";

    # Dedicated
    nvidiaBusId = "PCI:01:00:0";

    # Enable iGPU/dGPU switching
		offload = {
			enable = true;
			enableOffloadCmd = true;
		};
	};

}

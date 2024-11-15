{ pkgs, lib, config, ... }:

{

## See https://nixos.wiki/wiki/Nvidia

## Tools
  environment.systemPackages = with pkgs; [
    nvtopPackages.full
  ];

## Enable Nvidia hardware acceleration
  hardware.graphics = {
    enable = true;
    };
  services.xserver.videoDrivers = [ "nvidia" ]; #this covers wayland too

## Add Nvidia kernel module if system boots to text
#  boot.initrd.kernelModules = [ "nvidia" ];
#  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
## Disable iGPU
#  boot.kernelParams = [ "module_blacklist=amdgpu" ];

## General Nvidia config
  # Version pinned to 535 due to kernel panics on nixbook
  # See https://nixos.wiki/wiki/Nvidia#Running_the_new_RTX_SUPER_on_nixos_stable
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # use closed-source driver
    nvidiaSettings = true; # accessible via `nvidia-settings`.
    package = let
    rcu_patch = pkgs.fetchpatch {
      url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
      hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
    };
in  config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "535.154.05";
      sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
      sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
      openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
      settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
      persistencedSha256 = "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";
      patches = [ rcu_patch ];
    };
  }; 

  # This is specific to nixbook; will need custom options if other systems need hybrid Nvidia graphics
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

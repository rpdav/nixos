## Description

This system is a Rasbperry pi 4 which is used for retro game emulation. This setup assumes most rebuilding will be done on a separate `x86` host with `boot.binfmt.emulatedSystems = ["aarch64-linux"];` set.

## Pi hardware flakes

There are some pi-focused flakes that may be better optimized for the pi's hardware, but I had limited success with them. Here are some that I tried and issues I ran into:

### [nixos-hardware](github.com/nixos/nixos-hardware)
* The default options pull a custom kernel which must be manually compiled. This can be overridden with `boot.kernelPackages = pkgs.linuxPackages"
* I may revisit this later to pull in some of the other custom options

### [raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix)
Repo is archived; didn't pursue this much |

### [nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi)
* There are alternate kernels which are supposedly in the binary cache, but I never got them to pull from the cache 
* The main thing I wanted to use this repo for was the ability to install with `nixos-anywhere` or `disko-install`, but had trouble with both:   
  * `nixos-anywhere` ran into a kexec error; I'm not sure why it was trying to use kexec since I was installing to a pi booted into nixos   
  * `disko-install` directly onto the sd card also failed; but so did manually partitioning and trying to install with `nixos-install`

Since declarative partitioning wasn't going to work, I just abandoned using any of these extra flakes.

## Install
### Differences to other hosts
Unlike my `x86` hosts, the `retropi` host is installed by flashing an image onto the SD card used for boot; it is not provisioned using a live iso or a through `nixos-anywhere`. Therefore, this host is different in a few ways:

1. It uses a fat32 `/boot` partition and an ext4 `/` partition, rather than btrfs
2. Since it is pre-partitioned, `disko` is not used. The filesystems are declared in `hardware-configuration.nix` like a vanilla non-`disko` system.
3. The system is not impermanent.

### Install procedure
1. Download a copy of the sd card image from [hydra](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)
2. Flash the image to an sd card.
3. While it's mounted on the provisioning host, make sure the sd card has any needed files in the proper places, such as:
  * `/etc/ssh`: ssh server keys that have been previously added to sops
  * `/etc/ssh/authorized_keys.d/root`: add pubkeys to be able to initially ssh into for rebuilding
  * `/home/<user>/.config/sops/age/keys.txt`: age keys for each user on the system
  * `/etc/NetworkManager/system-connections/<ssid>.nmconnection`: nmconnection file with wireless network credentials if provisioning over wifi
4. Boot the pi with the sd card and rebuild from the provisioning host with `nixos-rebuild boot --flake github:rpdav/nixos#retropi --target-host root@<pi-ip>`
5. Reboot the pi and it should be up and running

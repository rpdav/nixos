# Pi setup notes
## initial imperative setup
Pull down sd card image from hydra and flash to sd card. It contains:
* 32 MB fat partition
* ~4 GB EXT4 partition

This may be a good time to copy over ssh keys, etc.

It's a minimal install - no etc or home to start with

### first boot
First boot takes a bit longer - doesn't seem like it'll recognize the boot volume at first
ext4 FS gets expanded on first boot

After reboot (with systemctl poweroff), couldn't get display. Toggling the kvm seemed to help

### first rebuild

Accidentally made it a flake build (even without `nixos-rebuild switch --flake`) because flake.nix was in /etc/nixos. Didn't even require --extra-experimental-features

Seemed to build fine, but got a "fatal error-code 45" from rpi bootloader when trying to boot.

Rebooting again and hitting escape during bootloader process seemed to make it work. Hard to know what's going on because display doesn't initialize right away.

### remote deploy on separate flake
need `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];` to allow emulation.

starting with just native `nixos-rebuild` tooling; I'm not sure how nixos apply would work here yet.

That seemed to work, although I couldn't ssh in as root. used regular user and sudo

### Bring into main config
Had to set nix.settings.trusted-users to `["@wheel"]` but that's because ssh as root was messed up. Shouldn't be needed in main config.

Worked as easily as separate flake

### Flesh out rpi config
[x] core packages
[x] secrets, ssh, etc
[ ] nvf (rebuild with cache enabled)
[x] nixos-hardware (need to fix kernel cache miss)

nvf still seems to need to compile dotnet even with cache enabled. stopped after 4.75 hours. Will have to omit from pi for now. Would nixvim be better?

retroarch install seemed to work fine. swapped out snes9x for bsnes because 9x is unfree and had to be compiled

performance is OK for snes and gba. DS and GCN are choppy - especially audio. Don't have a 64 to test. enabling pipewire didn't help. 

### try alternate raspberry pi flakes

#### [nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi)

The imports described in the section about using `nixpkgs.lib.nixosSystem` are incorrect - check these against the actual flake outputs.

At a minimum, need the base image imported.

Getting an error that `services.displayManager.generic` does not exist when rebuilding using the custom system builder function. I think this is because the nixos-raspberrpi flake is based on stable pkgs, but the rest of my config (specifically stylix) is pulling the `generic` option from unstable, which doesn't exist in stable. Can overcome this by having nixos-raspberrypi follow nixpkgs, but then I'll miss out on the binary cache. Maybe skipping binary cache is OK as long as I stick with nixpkgs kernel; what I want most is the integration with disko.

The default options from `nixos-raspberrypi` seem to not conflict with current setup. Will leave these options alone for now and move on to disko testing; can do more tweaking later. Things to revisit:
* hardware options (bluetooth, wlan)
* get `nixos-raspberrypi` cache working and try other kernels

#### [raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix)

Repo is archived; skipping for now.

### Reinstall/redeploy

Skipping - going directly to disko setup

Coming back after having trouble with disko below. Followed these steps:
1. flashed sd card with official image from hydra
2. copied over ssh and age keys (need to be mindful of permissions here - rebuild failed because ownership of `/home/ryan` wasn't changed to `ryan` recursively.
3. booted up pi and set root pw to allow ssh
4. pushed a rebuild over ssh, omitting all `disko` and `nixos-raspberrypi` config (having it enabled caused rebuild to fail due to boot issues.
5. reboot and system is back up

rebuilding again with `nixos-raspberrypi` is still failing; not sure why it was working before. 

## Declarative deploy

nixos-anywhere failed, saying kexec didn't work. not sure why kexec would be needed since it's already running nix? may need to read about kexec on arm on the nixos-anywhere project. For now going to focus on using disko-install on the sd card on another system

### Create ext4 disk with disko
doing a fat /boot and ext4 / led to disko-install saying it failed. the ext4 partition was formatted and installed, but boot was empty (and not mounted). trying again with a simple ext4 and no extra boot partition.

disko-install with ext4-only also failed - said it could not find the activation binary and bootloader was not installed.

repeating with nixos-install led to the same error. A [2023 discourse thread](https://discourse.nixos.org/t/nixos-install-and-nixos-enter-chroot-failed-to-run-command-nix-var-nix-profiles-system-activate-no-such-file-or-directory/32071/15) talked about this, but no solution; they just did a manual install instead.

### Create btrfs disk with disko

skipped

### Update deployment tooling
* make sure `nixos apply` just commands work for arm systems
* update ssh hosts

## Final config

[ ] try to enable more rpi-hardware config
[ ] make different user

will not use disko or impermanence

### USB drive boot?

### Retroarch displayManager

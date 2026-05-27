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

#### [raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix)

Repo is archived

### Reinstall/redeploy

## Declarative deploy

### Create ext4 disk with disko

### Create btrfs disk with disko

### Update deployment tooling
* make sure `nixos apply` just commands work for arm systems
* update ssh hosts

### USB drive boot?

## Final config

[ ] try to enable more rpi-hardware config
[ ] make different user

### Retroarch displayManager

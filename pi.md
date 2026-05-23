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

### Flesh out rpi config

## Bring into main config

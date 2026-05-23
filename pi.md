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

## Move to standalone flake config

## Bring into main config

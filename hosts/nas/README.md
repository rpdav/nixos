# NAS install notes

## ZFS
Want to check a couple approaches to managing ZFS:
1. Importing a previously imperatively-made pool. This is probably what I'll do with the current NAS drives.
1. Declare them in disko. Need to make sure this can be done non-destructively for drives with data

Current disks on nas have mountpoints explicitly declared (/mnt/storage, /mnt/docker) as zfs filesystem properties. This conflicts with `filesystems."/mnt/tank"` even if systemd.services.zfs-mount is disabled as recommended by the wiki. Will cause systemd to drop to emergency mode unless emergency mode is disabled. May need to set the mountpoint to legacy if going the non-disko route.

# NAS install notes

## ZFS
Want to check a couple approaches to managing ZFS volumes:
1. Importing a previously imperatively-made pool. This is probably what I'll do with the current NAS drives.
1. Declare them in disko. Need to make sure this can be done non-destructively for drives with data

### Mount in default.nix
Current disks on nas have mountpoints explicitly declared (/mnt/storage, /mnt/docker) as zfs filesystem properties. This conflicts with `fileSystems."/mnt/tank"` even if systemd.services.zfs-mount is disabled as recommended by the wiki. Will cause systemd to drop to emergency mode unless emergency mode is disabled. May need to set the mountpoint to legacy if going the non-disko route.

### Mount with disko
Disko won't mount new disk configs on an already-installed system. But when I deleted the 2 partitions per disk (main partition plus the extra 8 MB EFI partition) and re-installed with anywhere, it mounted them and the data was even there too (although only a single partition per disk). Will retry without deleting the partitions - this may be a good way to import during install.

I created 2 pools on nas using zvols and passed them through to an installer environment. I deleted the partitions for one of the pools and its filesystems were preserved but the content wasn't. filesystems were not preserved for the one that wasn't deleted.

### Misc notes
I currently persist ${serviceOpts.dockerDir} in the impermanence module. This causes a config collision with the zfs mounts because zfs is trying to mount /mnt/tank to the zpool but impermanence is trying to mount it to /persist.

Maybe mount it into /persist and let impermanence bind mount it over to /mnt/tank?

I could also move the docker directory over to /persist and not do any symlinking into /opt or /mnt/tank.

## Docker
Home assistant and nextcloud have reverse proxy settings that may need tweaked on migration.

## Backup

### Contents

* NAS
	- persist
		+ etc/ssh
		+ home/{username}
	- /mnt/storage/media
	- /mnt/docker
		+ photos
		+ nextcloud
		+ appdata
	- /mnt/vms
* VPS
* FW13

### Roadmap

- [x] Delete old snapshots
- [x] Set up sanoid
- [x] Set up local zfs send/receive backup
- [ ] Set up non-zfs service
	- [ ] rclone mount
	- [ ] run borg
	- [ ] rclone unmount
- [ ] Set up zfs service
	- [ ] (recursively) snapshot filesystems
	- [ ] rclone mount
	- [ ] run borg
	- [ ] rclone unmount
	- [ ] delete snapshots

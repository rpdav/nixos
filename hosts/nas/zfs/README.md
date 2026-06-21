# NAS ZFS notes

The main config difference between NAS and my other systems is the data drives, so most of this config is in `system/hosts/nas/zfs` rather than common.

ZFS pools were previously created in Unraid, so they are imported as filesystems in `default.nix` rather than in disko. I'd probably use disko if starting out from scratch. I did some experimenting with importing previously-created pools with disko in a test environment but sometimes got data loss, so manual it is.

Below is the high level filesystem structure:

```code
.
├── docker          Mirrored zpool using 256 GB sata SSDs
│   ├── appdata     Contains child filesystems for each service I run. This lets them receive independent snapshots so they can be rolled back individually if needed.
│   ├── nextcloud   Data directory for Nextcloud (app config is still in appdata)
│   └── photos      Data directory for photos. I don't have a ton so they're on ssds for performance on Immich
└── storage         Mirrored zpool using 4 TB sata HDDs
    ├── backups     Target for all local backups, including FW13 host (using borg), Windows laptop (using Veeam), and some legacy data from Unraid
    ├── isos        For real, this is actually linux ISOs
    ├── media       iTunes media which is mounted into a Windows VM, as well as some backed up DVDs
    └── syncoid     docker and vms pools synchronize to this filesystem. I consider this the 'local backup' for that data
```

## Import and mounting
There are 2 main ways to import zpools in Nixos:

1. Set the zfs mountpoint property to `legacy` and mount using `fileSystems.mountpoint`. This will **not** auto-mount child filesystems.
2. Set the zfs mountpoint property to the desired mountpoint and import using `boot.zfs.extraPools`. This **will** auto-mount child filesystems.

2 is obviously preferable for pools with child filesystems, however I could not get my config to import any pools if they are all imported using `boot.zfs.extraPools`; at least one had to use method 1. So since my `vms` pool does not have any child filesystems on it, that one gets mounted with method 1, and the others with method 2.

## Drive encryption

ZFS drives are encrypted with luks. The easiest way I found to unlock them is to use the same passphrase as for the root drive. To enable remote unlocking, I enabled an initrd ssh server so I can enter the passphrase remotely.

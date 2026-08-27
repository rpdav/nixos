# Backup and Restore

## Backup strategy

### Overall design
All systems back up data from their `/` (or `/persist` for impermanent systems) partitions daily using `borg`. `borg` connects over ssh to a `borgbackup` container running on on `nas`. Backups are stored on a mirrored hard drive zpool (`storage`). Repositories are titled "`host`-`user`" where `user` is "root" for system backups.

### System and user modules

Both system and user backup modules make use of [custom options](./options.md) defined in `modules.generic.customOptions`. Values are assigned in host- or user-specific configuration, and are then consumed by one of the two backup modules.

`nixosModules.backup` uses `services.borgbackup` to back up system-level data on `/` (or `/persist` for impermanent systems). The module decrypts the borg ssh key and passphrase, adds borg's public key as a known host (the service silently fails if the host isn't already known), and adds ssh config so the correct key is used. Paths to include or exclude are defined in host configuration using `backupOpts`.

`homeModules.backup` uses `services.borgmatic` to back up user-level data. It's similar to `nixosModules.backup` but handles patterns a little differently. `backupOpts` must be defined in the user's home configuration.

### Host-specific differences

#### fw13

This is my only host with user backup for `ryan`. The other hosts also have the same user, but no data, so there's nothing to back up.

#### nas

In addition to the minimal data to backup on `/persist`, nas has several zfs filesystems. All filesystems on the ssd mirror `docker` are cloned to the hdd mirror `storage` using syncoid. See the [zfs readme](../hosts/nas/zfs/README.md) for more details.

### Security, keys and passphrases

All secrets, including the ssh private keys and borg repository passphrases are handled using [sops-nix](../_nix-secrets/README.md). Each host or user that will use the backup module will have an `id_borg` ssh key. This key is not protected by a passphrase because its use is automated through systemd services. However, this key does not work to access the nas host directly; only the `borgbackup` container. Additionally, within the `borgbackup` container, these keys only allows connections to the `borg serve` process within it; you can't ssh directly into the container. The corresponding public keys are mounted into the `borgbackup` container such that each user or system's key only allows access to its `borg` repository. The container will not allow a compromised vps to access fw13's repository because vps does not have access to fw13's key. I
n addition to the host- and user-specific keys, each repo is also accessible through a resident security key that lives on a yubikey as a backup/boostrapping key.

The cleanest and most secure way to handle passphrases would be to have an independent passphrases for each user and host. Hosts would not be able to decrypt other hosts' secrets, nor would users be able to decrypt other users' secrets. Hosts would be able to decrypt the secrets of users that exist on their system because root can read users' age keys in `~/.config` but they can read the users' data on-disk anyway. However, this strategy would allow a compromised `vps` to access the backup for `ryan`. `vps` already has access to user `ryan`'s secrets (it has to at least for the user's password hash) and could access both the borg ssh key and passphrase. The user's borg ssh key and passphrase are not automatically decrypted since user backup is not enabled for `ryan@vps`, but it would be trivial to do so if an attacker is familiar with `sops`. This would give a malicious user on vps access to all of ryan's personal files.

Instead, passphrases are stored in the system-level `sops` files. All users on a host (including root) use a common passphrase to decrypt their repositories, so the passphrase decrypted with world-readable permissions on the host. Users still cannot access other users' backups since they do not have their ssh keys. And hosts still cannot access other hosts' backups because they do not have those hosts' ssh keys or passphrases.

## Offsite backup

`modules.nixos.rcloneSync` allows users to define source and target directories to synchronize to an `rclone` endpoint such as Backblaze or Proton. This module assumes an `rclone.conf` file is available and can be pointed to its path. I have one defined using `sops-nix` templates in `nixosModules.rclone`. I use backblaze B2 as the remote and encrypt locally (using an rclone `crypt` remote) for any data that isn't already encrypted.

This module enabled on `nas` only since it already contains the backups from the other systems. 

## Recovery
 
These are more notes for myself on how to go about various restore scenarios. This supplements general install procedures in the [install docs](./install.md).

### Main host fw13 dead

1. Install the `install` host
2. Restore secrets:
```bash
# download the bootstrap ssh resident key
ssh-keygen -K

# make temporary mount directory
mkdir /tmp/borg

# mount and restore system secrets
borg --rsh="ssh -i ./id_ed25519_sk_rk" mount ssh://borg@10.10.1.17:2222/backup/fw13-root /tmp/borg
sudo rsync /tmp/borg/_latest_backup_/persist /

# mount and restore user secrets
borg umount /tmp/borg && borg --rsh="ssh -i ./id_ed25519_sk_rk" mount ssh://borg@10.10.1.17:2222/backup/fw13-ryan /tmp/borg
sudo rsync /tmp/borg/_latest_backup_/persist /
```
3. Rebuild
```bash
sudo nixos-rebuild boot --flake github:rpdav/nixos#fw13
```

### Backup target nas dead

1. Pull down `nas` borg repo from rclone
2. Stage secrets for deployment:
```bash
# make temporary mount directory
mkdir /tmp/borg /tmp/nixos-anywhere

# mount and restore system secrets
borg mount /path/to/repo/nas-root /tmp/borg
rsync /tmp/borg/_latest_backup_ /tmp/nixos-anywhere
borg umount /tmp/borg
```
2. Boot `nas` into live iso
3. Deploy `nas` with secrets using `nixos-anywhere`
4. Restore data
```bash
sudo rclone sync B2:rpdav-rclone/borg /mnt/storage/backups/borg
sudo rclone sync B2-crypt:appdata /mnt/docker/appdata
# repeat for remaining targets
```

### Other host (not fw13 or nas) dead

### Disaster recovery - fw13, nas, and bootstrapping yubikey are lost




Things to cover:
* what's backed up for each system
* zfs backups with syncoid
* ssh keys for borg and permissions
* host-specific differences
* user vs system backup
* shared system passphrases
* backup testing commands - put in justfile?



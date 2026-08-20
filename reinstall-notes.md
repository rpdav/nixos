
I think the rollback script is not working as intended

Why do these subvolumes keep disappearing? Is it a btrfs thing?

## stuff that wasn't backed up - seems like mostly stuff in .files?
* firefox bookmarks
* firefox history
* user age keys in .config
* known hosts in /persist/home/ryan/.ssh/known_hosts
* fprintd - restore may have been before it was set up

## stuff that needs fixed
* local backup
* remote backup (switch to proton?)
  * would probably be best to use separate credentials per host for proton if possible
* need better secrets bootstrapping for reinstall - add pubkey to other hosts besides borg?
* permissions were messed up after reinstall. not sure if it was in /persist or /home or some of both

## secrets bootstrapping
Added bootstrap key to borg repo for fw13 and to user ryan. This should cover all use-cases

ssh agent is making it difficult when yubikey is present; will test during next reinstall

## figure out permissions handling
the tmpfiles rules in ./users/ryan/default.nix has Z (recursively chown) and z (non-recursively chmod) rules for /persist/home/ryan

there was a typo in the Z rule; fixed

## local backup
### user module
if the borg key isn't added to known hosts, systemd service will fail. have to run it imperatively and accep the new key. Maybe the borg pubkey should be added to known hosts in config?

borg mount seems to have to be run with sudo even if user is in fuse group. this makes the mounted directory owned by root which is a pain

if mount fails with a bunch of python errors, i might have the repo mounted on another system.

borgmatic module docs say source_directory and patterns are mutually exclusive. But I can't get it to run without having source directories manually added to yaml. Even then, patterns don't seem to be running properly. It's also adding random stuff to repo like the borg config config in yaml. That might be default behavior though.

Patterns were set wrong - needed an "R" pattern to establish recursion root

Seems to be working now - but the mount/restore process is clunky. Need to make it smoother (maybe a script or alias?) if I'm going to be likely to test backups

Looks like it's backing up every hour? changed to daily

### system module
it doesn't seem to be connecting to the repo. this could be an issue of which keys are allowed access to which repos. restructured borg repo to have independent keys/backup folders for root and for user. Also, no nesting of system/user within a single host folder.

Switching to the flat structure fixed it. It would still sometimes fail since it detected the repo had moved. But I just deleted the old repo and it backed up fine.

## secrets handling

Want to prevent vps host from having access to backups from other systems. By default host vps has access to any secrets in ryan.yaml. Should put either the ssh key or passphrase in host.yaml, but set permissions for users to be able to access. Definitely want separate keys per system, and maybe also passphrases. Passphrases could live in user.yaml.

Actually, I don't think ssh keys can be shared between users - ssh will fail if the key is world-readable. Maybe better to have a key in common.yaml but separate system passphrases?

I think I'll just segregate everything. Sure, vps can read ryan's ssh key but it won't be able to get into the repo.

Confirmed through testing that vps can't access any other repos

## nas and vps local backup

This seems to be working, but had to manually ssh into it to get the key added. need to get the key and pubkey into config to prevent this

## remote backup

borg doesn't like not having fast filesystem access (e.g. not cloud remotes). It would be better to sync existing repos on the nas to the cloud with rclone rather than mount rclone and backup to it.

The remote backup module will be retooled to only rclone sync up to B2 on nas. 2 buckets will be used:

1. regular bucket for encrypted borg repos
2. encrypted bucket for all else (media, photos, appdata, nextcloud)

media and photos are already compressed, but appdata (11G) and nextcloud (7G) are not. Some stuff can be cleaned up.

This means there will be no remote version history for nas data - only the most recent snapshot plus B2's retention policy. Will use zfs snapshots for local history.

Syncoid snapshots are best to use for nas data since they're static, but they're not mounted (see duplicati errors). Could run a pre-start script to mount them?

I think this would work well as a standalone module. There are going to be lots of systemd service and timer submodules. Would be much cleaner with custom options. Something like:
```nix
config = {
  rclone = {
    configFilePath = config.sops.templates."rclone.conf".path;
    backups = {
      borg = {
        sourceDir = /mnt/storage/backups/borg;
        remote = "B2:rpdav-rclone";
        targetDir = "borg"; # default to final dir in sourceDir
        frequency = "weekly";
      };
      media = {...};
    };
  };
};
```

## backup strategy
### local
1. fw13
  1. user: borg backup all user data (including age keys) to nas HDDs.
  2. root: borg backup ssh and secure boot keys to nas HDDs. no data to speak of
2. vps
  1. user: none
  2. root: borg backup ssh keys to nas HDDs. won't bother with DMS data
3. nas
  1. user: none
  2. root: borg backup /persist/etc to nas HDDs.
  3. docker zpool: syncoid filesystems (appdata, nextcloud, photos) to nas HDDs
  4. storage zpool: no backup beyond zpool mirror. This includes media and isos.
4. vm: none? It's mostly just steam data, which is restorable

### remote
nas will rclone sync borg backups to B2. Just the usual bucket since they're already encrypted.

nas will also rclone sync nas data sets (appdata, nextcloud, photos, and media) to B2-crypt. Need to figure out how to mount the syncoid filesystems before transferring.

## documentation

need docs for:
1. backup strategy and design
2. routine checks
3. restore
4. disaster recovery

## TODO
- [x] fix permissions
- [x] add bootstrap key
- [x] get local user backup working again
- [x] get local root backup working again
- [x] check other system local backup
- [x] create per-system keys and credentials
- [x] increase borg passphrases to 6 words
- [ ] get remote backup working
- [ ] make it easier to mount/restore backup
- [ ] encrypt win10 vm

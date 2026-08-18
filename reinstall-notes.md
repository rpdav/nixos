
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

## TODO
- [x] fix permissions
- [x] add bootstrap key
- [x] get local user backup working again
- [x] get local root backup working again
- [ ] check other system local backup
- [ ] create per-system keys and credentials
- [ ] get remote user backup working
- [ ] get remote root backup working
- [ ] make it easier to mount/restore backup

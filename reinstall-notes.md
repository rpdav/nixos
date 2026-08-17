
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
if the borg key isn't added to known hosts, systemd service will fail. have to run it imperatively and accep the new key. Maybe the borg pubkey should be added to known hosts in config?

borg mount seems to have to be run with sudo even if user is in fuse group. this makes the mounted directory owned by root which is a pain

if mount fails with a bunch of python errors, i might have the repo mounted on another system.

### test folder

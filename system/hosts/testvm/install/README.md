# Remote Nixos Install

## nixos-anywhere notes:

`nixos-anywhere` authenticates over ssh several times in the install process, so if keys are used it will prompt for the passphrase or yubikey touch several times. If it times out, the install will abort and the machine will be unbootable. If using password ssh, it only asks once. If there will be several rounds in a testing environment, password is much more convenient.

`nixos-anywhere` expects to be run in the same directory as `flake.nix`. It won't seach upward like `nixos-rebuild`

`nixos-anywhere` can either install onto a machine booted into a nixos installer or onto a separate booted linux distro by using kexec. The docs say that a minimum of 1 GB RAM is needed for kexec, but I had better luck with 2 GB.

## Initial Prep

1. Boot into install environment (or use a running linux server)
2. Ensure root user has a password set and can be `ssh`ed into either using password or keys
3. Update config file with target disk (verify with `lsblk`) and ssh pub keys

## Installation on New Host

1. Run `nix run github:nix-community/nixos-anywhere -- --flake .#<hostname> --generate-hardware-config nixos-generate-config ./system/hosts/<hostname>/hardware-configuration.nix root@<IP>`
2. After reboot, the machine will successfully boot but won't have secrets. Password login will be disabled, but you can ssh into it.
3. Restore user age key by copying key from current host or backup to `~/.config/sops/keys.txt` on the remote host
4. Set up host ssh keys:
	1. Add the new host's ed25519 private key to `nix-secrets`
	2. Generate an age pubkey from the host ssh pubkey: `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age`
	3. Add the age pubkey to `.sops.yaml` in `nix-secrets` and apply the key with `sops updateKeys secrets.yaml`
	4. Commit and push the changes to `nix-secrets`
	5. Back in the nixos repo, update the `nix-secrets` input
5. Rebuild the machine with `nixos-rebuild --flake .#<hostname> --target-host root@<ip> boot` and reboot

## Reinstall of existing host

1. Copy backed up files to `/tmp/backup` or similar directory. This directory should mimic the root of the target host (e.g. `/tmp/backup/persist`, `/tmp/backup/etc`). At a minimum this should have the user age key in `~/.config/sops/keys.txt` and host ssh key in `/etc/ssh`. Docker appdata should be copied as well to prevent the containers from creating boilerplate data that will have to be replaced later
2. Run `nix run github:nix-community/nixos-anywhere -- --flake .#<hostname> --extra-files /tmp/backup --generate-hardware-config nixos-generate-config ./system/hosts/testvm/hardware-configuration.nix root@<ip>`
3. After reboot, the machine should be fully restored. `nixos-anywhere` copies files from `/tmp/backup` preserving permissions but assigns ownership to root. This config includes `tmpfiles` Z rules to correct ownership in `~` and the docker service directories.

## Remote rebuilding
Rebuild remotely using `nixos-rebuild --flake .#<hostname> --target-host root@<ip> switch`. `sudo` isn't necessary since you're connecting as root. If you use `sudo` it will try to use root's ssh keys.
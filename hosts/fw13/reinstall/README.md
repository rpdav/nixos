## Partition and Install

1. Boot into installer, clone this repo, and cd into the reinstall folder
1. Review `disko.nix` and `configuration.nix` for any needed edits.
1. Partition the drive by running `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./disko.nix`. Enter the disk encryption password when prompted.
1. Generate a hardware config by running `sudo nixos-generate-config --no-filesystems --root /mnt`
1. Move  `configuration.nix` and `disko.nix` to /mnt/etc/nixos
1. Run `sudo nixos-install` and enter root password when prompted
1. Reboot

## Restore and rebuild

1. Restore persistent data from backup, using a temporary ssh client key to get into borg if needed
1. If setting up a brand new host, secrets must be bootstrapped:
	1. Copy the restored user age key from `/persist/home/user/.config/sops` to `~/.config/sops` to allow secrets to be edited
	1. Clone the `nix-secrets` repo and cd into it
	1. Create a new age pubkey from ssh host key by running `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age` and add it to `.sops.yaml`
	1. Update `secrets.yaml` with the new key by running `sops updateKeys secrets.yaml`
	1. Copy temporary ssh client pubkey to gitea and commit/push changes.
	1. Copy the new ssh host keys over to `/persist/etc/ssh`
	1. Clone the main repo and pull down the updated secrets by running `nix flake lock --update-input nix-secrets`
1. Copy /etc/nixos/hardware-configuration.nix to git directory and `git add` it
1. If edits to the config during partitioning, add them here too
1. Rebuild with `sudo nixos-rebuild boot --flake .#hostname`

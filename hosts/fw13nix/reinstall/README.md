WIP
 
Rough plan:
1. Boot into installer
2. Pull hardware config w/o filesystems
3. Partition with disko (maybe using disk config w/o custom options)
4. Install
5. OR instead of 3 and 4, install directly using disko-install
6. Reboot into new OS
7. Restore persistent data using temporary ssh key
8. For brand new host:
    8a. Generate new sshd keys
    8b. Pull and update sops repo with sshd keys (need to copy user age key to ~/.config/sops)
    8c. Push sops repo and update flake input
9. Update config with new hardware-configuration.nix and rebuild


Method 1:

## Install

1. Boot into installer
2. Clone repo
3. cd to reinstall folder
4. partition `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./disko.nix` and enter disk encryption password when prompted
5. generate config `sudo nixos-generate-config --no-filesystems --root /mnt`
6. move repo configuration.nix and disko.nix to /mnt/etc/nixos
7. `sudo nixos-install` and enter root password when prompted

## Restore and rebuild

1. restore persistent data from backup, use temp ssh key to get into borg if needed
2. if new host, 
    generate new age pubkey from ssh host key `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age`
    copy temp ssh pubkey to gitea to allow push
    copy /persist/home/ryan/.config/sops to ~/.config/sops to allow secrets editing
    add new age key to .sops.yaml and push up to gitea
    copy sshd keys over to persist
    push changes up to secrets repo
3. update secrets nix flake lock --update-input nix-secrets
4. copy /etc/nixos/hardware-configuration.nix to git directory and git add it
5. sudo nixos-rebuild boot --flake .#hostname

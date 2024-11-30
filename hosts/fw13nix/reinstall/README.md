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

1. Boot into installer
2. Clone repo
3. cd to reinstall folder
4. partition `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./disko.nix`
5. generate config `sudo nixos-generate-config --no-filesystems --root /mnt`
6. move repo configuration.nix and disko.nix to /mnt/etc/nixos
7. `sudo nixos-install`

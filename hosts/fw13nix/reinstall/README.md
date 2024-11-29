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

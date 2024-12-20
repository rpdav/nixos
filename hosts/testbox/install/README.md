install command: nix run github:nix-community/nixos-anywhere -- --flake .#testbox --copy-host-keys --target-host root@testbox

Rebuild command: just testbox

sops does require the target machine to have valid keys. so this will need to be copied over to /etc/ssh or /persist/etc/ssh before doing full rebuild

at a minimum, a non-sops password for users must be present for first install. could be hashedPassword (which overrides hashedPasswordFile I think?). initialPassword is overridden by mutableUsers = false.

or maybe just let password login break and log in by ssh key

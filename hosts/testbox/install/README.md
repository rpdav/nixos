# Install
boot up iso
sudo -s
set passwd
lsblk to determine disk
install command: nix run github:nix-community/nixos-anywhere -- --flake .#testbox --copy-host-keys --target-host root@testbox

# Remote rebuilding
Rebuild command: just testbox
This tends to default to root's ssh key instead of ryan's yubikey. copied its pubkey to the config for now
maybe because I'm running sudo? do you need sudo to nixos-rebuild a different machine as long as you're sshing in as root?

# Secrets
sops does require the target machine to have valid keys. so this will need to be copied over to /etc/ssh or /persist/etc/ssh before doing final rebuild

install with standard hashedPasswordFile entry
password login is broken on reboot but you can ssh in with keys
copy keys to /persist/etc/ssh from /etc/ssh or backup
if new host, add the ssh pubkey to nix-secrets and push/pull
bam



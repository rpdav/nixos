# Install
boot up iso
sudo -s
set passwd
lsblk to determine disk
install command: nix run github:nix-community/nixos-anywhere -- --flake .#testbox --copy-host-keys --target-host root@testbox

# Remote rebuilding
Rebuild command: just testbox
make sure you're not using sudo for nixos-rebuild, otherwise it'll try to use root's ssh keys. no need for sudo as long as you ssh in as root

# Secrets
sops does require the target machine to have valid keys. so this will need to be copied over to /etc/ssh or /persist/etc/ssh before doing final rebuild

install with standard hashedPasswordFile entry
password login is broken on reboot but you can ssh in with keys
copy keys to /persist/etc/ssh from /etc/ssh or backup
if new host, add the ssh pubkey to nix-secrets and push/pull

# impermanence
I think impermanence is messing with ssh somehow. has been refusing port 22 using both the core module and a simple enable=true in the testbox module. logging in directly shows that there's no sshd_config file - not being persisted?

symlinking is ok, but the rollback script is not executing. throwing a boot error about `/btrfs_tmp` not being a btrfs filesystem. this seems identically set up to fw13 host so not sure what's wrong.

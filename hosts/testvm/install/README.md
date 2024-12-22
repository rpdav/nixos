# Install
boot up iso
sudo -s
set passwd
lsblk to determine disk
install without keys: nix run github:nix-community/nixos-anywhere -- --flake .#testvm --generate-hardware-config nixos-generate-config ./hosts/testvm/hardware-configuration.nix root@10.10.1.19
install and restore files: nix run github:nix-community/nixos-anywhere -- --flake .#testvm --extra-files /path/to/files --generate-hardware-config nixos-generate-config ./hosts/testvm/hardware-configuration.nix root@10.10.1.19
where /path/to/files has a structure that mirrors what will be on the host (e.g. /path/to/files/persist/foo/bar).

# Remote rebuilding
Rebuild command: just testbox
make sure you're not using sudo for nixos-rebuild, otherwise it'll try to use root's ssh keys. no need for sudo as long as you ssh in as root

# Secrets
sops does require the target machine to have valid keys. so this will need to be copied over to /etc/ssh or /persist/etc/ssh before doing final rebuild if it isn't copied over at install time

procedure for brand new host:
install with standard hashedPasswordFile entry
password login is broken on reboot but you can ssh in with keys
copy keys to /persist/etc/ssh from /etc/ssh or backup
if new host, add the ssh pubkey to nix-secrets and push/pull

# Impermanence
Persisting the entire /etc/ssh directory can cause trouble on new hosts. The order is:
1. nix builds the sshd config and places symlink files like sshd_config in /etc/ssh
1. impermanence sets up bind mounts and removes the contents of /etc/ssh
1. sshd creates keys (bind mounted to persist), but fails to start when it sees sshd_config is missing

If system is (or has been) rebuilt after boot, the symlinks get rebuilt into /persist and the problem goes away. But this causes issues when provisioning new systems (especially remotely). So just persist the keys and let the rest of the ssh directory stay impermanent and get rebuilt on boot.



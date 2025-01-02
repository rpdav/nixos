# Install
boot up iso
sudo -s
set passwd
lsblk to determine disk
install without keys: nix run github:nix-community/nixos-anywhere -- --flake .#testvm --generate-hardware-config nixos-generate-config ./hosts/testvm/hardware-configuration.nix root@10.10.1.19
install and restore files: nix run github:nix-community/nixos-anywhere -- --flake .#testvm --extra-files /path/to/files --generate-hardware-config nixos-generate-config ./hosts/testvm/hardware-configuration.nix root@10.10.1.19
where /path/to/files has a structure that mirrors what will be on the host (e.g. /path/to/files/persist/foo/bar).
Unlike rebuilding, anywhere must be run from within the same directory as your flake.

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

# Docker
Using podman

Use compose2nix just recipe to create oci containers and systemd services from docker-compose.yml. secrets will have to be manually added to the generated docker-compose.nix file since they get quoted if you add them direcly to the docker-compose.yml file. This means repeated running of compse2nix will overwrite those edits. A couple options to deal with this:
1. Only run compose2nix once and then delete docker-compose.yml. Any future edits will be in the docker-compose.nix file directly.
    * Pros: tweaks to docker-compose.nix don't get overwritten
    * Cons: need to have the know-how to edit docker-compose.nix directly, harder to incorporate upstream updates to docker-compose.yml
1. Keep docker-compose.yml around and use it for repeated rebuilds with compose2nix.
    * Pros: I know docker-compose.yml better, easier to bring in upstream updates
    * Cons: have to repeat those edits for secrets, volumes, etc. Git may be enough to preserve secrets while updating the file. If not, maybe a script to find/replace them?

For each service, create default.nix to import the auto-generated compose.nix file. Default will include (or import) reverse proxy subdomain conf and any other supporting files if needed. Swag's default will also include file for cloudflare token

## Docker secrets
Sops usually places a symlink at a desired directory to /run/secrets, but that will become a dangling secret within the container. Instead, mount /run/secrets/foo/bar directly in the compose file. 

## Directories for volume mounts
Docker/podman require directories for volume mounts to be in place - it won't create them. So they're created using systemd tmpfiles. Even if tmpfiles is told to create a directory owned by a user, it will create any needed parent directories owned by root. In the case of `/opt/docker/swag/config`, if `docker` is owned by a user and `swag/config` is created by tmpfiles, it will cause an unsafe transition error between `docker` (owned by user) and `swag` (owned by root). The solution here is keep everything aside from the final directory owned by root (but readable by all) if possible.

## Proxy configs
Each service's default.nix will contain a multiline string let binding with the nginx proxy config. This is converted to a single-line string and added as a tmpfile rule.

## Rootless
By default, podman can't be run rootless on Nixos. This may get fixed in [this pr])https://github.com/NixOS/nixpkgs/pull/368565). I tried enabling it with some extraInit [here](https://carlosvaz.com/posts/rootless-podman-and-docker-compose-on-nixos/) but didn't work. [Other solutions](https://discourse.nixos.org/t/podman-rootless-with-systemd/23536) seem pretty involved, especially [one for home-manager](https://discourse.nixos.org/t/rootless-podman-setup-with-home-manager/57905).

For now, I'm going to stick with Docker. Without rootless, podman offers no advantage over docker and requires all container admin to be done with sudo (as opposed to docker user group for ps and logs), so aliases don't work and vim doesn't look right. If I end up having to do a lot of sudo with docker (due to systemctl services), I may switch back to podman to ease the eventual switch to rootless.

## Docker vs podman differences
There are some differences that may cause trouble if I ever switch back to podman. For instance, the default dns resolver in podman was the network's gateway - 10.89.0.1. But for docker it's 127.0.0.11. I had to manually edit (or delete) /config/nginx/resolver.conf when I switched. May want to consider rebuilding appdata folders if I switch again in order to resolve this. Who knows what other differences are in there.

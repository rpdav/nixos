# Install and Reinstall
There are two methods for installing hosts from this config - locally via `disko` and remotely via `nixos-anywhere` (which uses disko under the hood). See the readme files in each host's subfolder for host-specific instructions.

## Creating a new host
To create a new host:
1. Create a new base host config in `./hosts/<hostname>` and a base user config in `./users/<user>`
2. If using home-manager, create a new base home config in `./home/<user>/<hostname>.nix`
3. Make sure all new files are staged before trying to rebuild

Secrets will need to be initialized for the host:
1. Generate an ed25519 ssh host key pair for the new host. Run `ssh-to-age -i /path/to/key.pub` to generate an age public key.
2. Add the new key to `.sops.yaml` in the secrets repo and run `sops updatekeys *` to add that key to the relevant files.
3. Commit and push the updated secrets.
4. In the main repo. Update the secrets input, commit, and push the updated `flake.lock` to the remote repo.

## Building a custom iso

This flake offers an `iso` host. It's nearly identical to official minimal (no gui) installer, but it comes with disko pre-installed. This helps with RAM constraints since disko will be installed on this iso itself instead of the tmpfs ramdisk.

You can build the iso with the command `nix build .#nixosConfigurations.iso.config.system.build.isoImage`

## Remote install

Remote install via `nixos-anywhere` is preferred since partitioning, install, and secrets can all be handled in one command. RAM constraints are much lower (2 GB needed for kexec) than for local install with `disko-install`. The minimum requirements for this method are 1) a target host booted into linux (live iso works too) and 2) a provisioning host running nix or nixos with flakes which can ssh into the target host as root.

1. At a minimum, copy the keys used by sops to `/tmp/nixos-anywhere` on the provisioning host, mimicking the directory structure they should have on the target system:
    1. ssh keys should be in `/tmp/nixos-anywhere/persist/etc/ssh`
    2. user age keys should be in `/tmp/nixos-anywhere/persist/home/<username>/.config/sops/age`
2. Install on the remote host with the following command:
```
nix run github:nix-community/nixos-anywhere -- \                           
--flake "github:rpdav/nixos#<hostname>" --extra-files /tmp/nixos-anywhere \
--generate-hardware-config nixos-generate-config \                         
./hardware-configuration.nix \                                             
root@<ip>                                                                  
```
3. Enter the disk encryption passphrase when prompted and reboot after install is complete
4. If the generated `hardware-configuration.nix` differs from the one the repo, commit and push the updated config to the repo for future rebuilds.

## Local install

Local installation is done using a live iso when another nix system is not available to bootstrap the new one. It is done using `disko-install` which combines both `disko` for declarative disk partitioning and `nixos-install` to install the actual config.

1. Boot into a live nixos environment such as one of the official isos from nixos or the custom iso in this repo.
2. If running one of the official isos, run:
```
sudo nix --extra-experimental-features "nix-command flakes pipe-operators" \ # first two are needed for flake support.
                                                                             # pipe operators are also used by my config. 
run "github:nix-community/disko/latest#disko-install" \                      # run the disko-install binary from the nix-community flake
--option extra-experimental-features pipe-operators \                        # pipe operators are not automatically enabled when disko-install runs nixos-install
--write-efi-boot-entries \                                                   # use this flag if the target drive is non-removable
--flake "github:rpdav/nixos#install" \                                       # tell it to install the minimal install host
--disk main /dev/sda                                                         # replace /dev/sda with your target disk. Don't worry about /dev/sda not being consistent across boots;
                                                                             # Future boots will be done using partition labels
```
3. If running on my custom iso, it's a bit simpler:
```
sudo disko-install \
--option extra-experimental-features pipe-operators \
--write-efi-boot-entries \
--flake "github:rpdav/nixos#install" \
--disk main /dev/sda
```
4. Enter the disk encryption passphrase when prompted.
5. Once install is complete, reboot
6. Once rebooted, copy the keys needed for secrets:
    1. ssh host keys go in `/etc/ssh` (or `/persist/etc/ssh` for impermanent systems
    2. User age keys go in `~/.config/sops/age`
7. Install the full system by running `sudo nixos-rebuild boot --flake "github:rpdav/nixos#hostname"`
8. Reboot to activate the full config

### RAM considerations
`disko-install` downloads the config to be built to `/nix/store` before partitioning the new drive. Since the iso is read-only, this all goes into a tmpfs ramdisk. My `fw13` config is too big for even 32 GB RAM, so I use a minimal `install` config for the initial install.

Even the minimal install has some RAM constraints - if using the official minimal iso, it requires 16 GB. If using my custom iso, it requires 8 GB. If you see an "out of disk space" error during install, you ran out of RAM.

### Alternative for low-RAM systems
The RAM constraints can be skipped by using `disko` instead of `disko-install`. This requires an independent disk config rather than a module. The disk configs in my repo will work as long as they are modified to remove any custom options (such as swap size).

1. Boot into an install environment
2. Clone this repo
3. Modify the disk config for use with `disko` as described above
4. Partition the disk by running: 
```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format.mount ./path/to/disk-config.nix
```
5. Install by running:
```
sudo nixos-install --option extra-experimental-features "nix-command flakes pipe-operators" --flake "github:rpdav/nixos#install"
```
6. Set up secrets as described in local install


# hosts/common
This is where all modules live that are used by multiple hosts. If any host-specific settings are needed, they can be made generic through the custom options defined in `variables.nix`. Default options are defined there but can be overridden in each host's config file.

For instance, two machines with different swap sizes can use a single disk config file by setting their own `systemSettings.swapSize = lib.mkForce "16G"`.

Similarly, they can all do backups to their own repository using the same backup config by defining the backup target as something like `ssh://borg@borg/backups/${config.networking.hostname}`.

If a module has to be truly host-specific, it goes in that host's directory.

## hosts/common/core
This contains any modules that are to be installed on **all** hosts. A single `default.nix` file imports all the other modules in this directory. That way, each host config only has to import `common/core` instead of `common/core/module1/2/3.nix`

If a module is used on *almost* every host, it doesn't belong here - it goes in optional.

## hosts/common/optional
This is where all other common modules go. Even if it's only being used on one host, if it could conceivably go on other hosts, it goes here.

## hosts/common/users
This contains a folder for each user in use in my config. It contains any user-specific **NixOS** config (not home-manager config). At a minimum, it defines the user and, if they use it, enables home-manager and points to their config in the home directory at `home/username/hostname.nix`

# hosts/<hostname>
This is where all host-specific NixOS config lives, like boot devices, hostname, hardware config, and system stateVersion. Any config that can be reused across hosts goes into `common`.

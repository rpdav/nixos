# Nixos Config

## Structure

* `flake.nix` contains inputs and outputs (currently just NixOS configs)
* `justfile` is a config file for [just](https://github.com/casey/just). Several commands were borrowed from [Ryan Lin](https://nixos-and-flakes.thiscute.world/best-practices/simplify-nixos-related-commands)
* `variables.nix` contains common system-related attributes like default usernames, architecture, and swap file size. The default values in this file can be overridden in each system's config. This lets me put more of my config in the `home/common` and `system/common` directories while still tailoring to each system. (NB these really aren't variables like are used in `let/in` bindings. They're actually custom options.)
* `home` contains home-manager configurations
  * `common/core` contains submodules that **all** home configurations should include
  * `common/optional` contains submodules that may or may not be included, like persistence configuration or desktop environment settings
* `hosts` contains system (NixOS) configurations
  * `common/core` contains submodules that **all** system configurations should include
  * `common/optional` contains submodules that may or may not be included, like graphics or sound settings
* `nix-secrets` see [Secrets](#Secrets)
* `themes` placeholder to build out stylix themes and wallpapers; currently just has wallpapers since I'm still building this out

## Secrets

`nix-secrets` is a root-level directory excluded from this repo. It is managed in a private nix-secrets repo defined in `flake.nix`. Even though contents are encrypted, I prefer they stay [reasonably private](https://github.com/getsops/sops?tab=readme-ov-file#weak-aes-cryptography). It contains 2 sources of secrets:

1. `secrets.yaml`: this is a sops-nix archive which is encrypted at rest. It is imported through the flake input `mysecrets` and decrypted at runtime.
2. `secrets.json`: this is in clear text on disk but is encrypted by git-crypt when pushed to a remote.

`sops-nix` is preferred since it does not leak cleartext secrets to `/nix/store`. But some modules do not support the `sops-nix` method of deploying secrets, which is `"cat ${sops.secrets.secretname.path}"`. In particular this does not work for `accounts.email.accounts.<name>.address` home-manager option which expects an input in the format of `name@domain.tld` - [example](https://discourse.nixos.org/t/is-there-a-way-to-configure-email-accounts-without-putting-personal-info-in-cleartext-home-manager/41216/2). It also does not work for endpoints in wireguard configs. So some secrets are imported directly from the json file where sops-nix does not work.

## Impermanence
[Impermanence](https://github.com/nix-community/impermanence) is a community module that during boot deletes all of `/` with the exception of `/boot`, `/nix`, and `/persist` (and optionally `/home`). NixOS rebuilds all the missing pieces during boot so that the system config accurately represents the real system state. This regularly purges any non-declarative cruft and keeps the system in a "fresh install" state.

Not everything can be fully declared in the NixOS config, so some critical files in `/etc` and `var` are symlinked to files in `/persist` using the impermanence module. There is a NixOS module (for persisting everything outside `/home`) and a home-manager module for dotfiles in `/home`.

### Methods of wiping `/`
The impermanence module does not include a function to wipe the non-persistent directories. This config uses btrfs subvolumes and wipes them using a script taken from the [impermanence repo](https://github.com/nix-community/impermanence?tab=readme-ov-file#btrfs-subvolumes). This script is also in this repo under `hosts/common/optional/persistence/rollback.nix`. This has the advantage of keeping a handful of recently deleted roots as btrfs snapshots. If I forget to persist something and reboot, it can be recovered by mounting that snapshot.

The other method is to use a tmpfs for `/`. This is simpler but takes up a lot of RAM.

### To persist `/home` or not
WIP: persisting .config versus its contents

## Disko
WIP

## Initial Install
WIP

## Acknowledgements
* [LibrePhoenix](https://github.com/librephoenix/nixos-config) - Phoenix's videos were a big help in setting up my initial system.
* [Ryan Lin's NixOS and Flakes book](https://nixos-and-flakes.thiscute.world/) - This was probably the single most helpful resource for me on understanding flakes.
* [Emergent Mind](https://github.com/EmergentMind/nix-config) - Helpful videos on SOPS and nixos-anywhere. I modeled the high-level structure of my config after his.
* [Vim Joyer](https://github.com/vimjoyer/) - Tons of videos on setting up a NixOS system, like impermanence, secrets, stylix, gaming...the list goes on!
* [NixOS: Everything Everywhere All At Once](https://www.youtube.com/watch?v=CwfKlX3rA6E) - This convinced me to jump down the NixOS rabbit hole.

## TODOs
* EmergentMind's relativetoroot feature

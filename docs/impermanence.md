# Impermanence

[Impermanence](https://github.com/nix-community/impermanence) is a community module that is designed with the intention of deleting all of `/` during boot with the exception of `/boot`, `/nix`, and `/persist` (and optionally `/home`). Most of the contents of `/etc`, `/usr`, and `/bin` are just symlinks to `/nix/store` and these are rebuilt at boot if they don't already exist. [GrahamC's blog](https://grahamc.com/blog/erase-your-darlings/) goes into further detail about why you would want to do this.

Not everything can be fully declared in the NixOS config, so some critical files in `/etc` and `/var` are symlinked or bind-mounted to files in `/persist` using the impermanence module. There is both a NixOS module and a home-manager module for files in `/home`.

## Methods of wiping `/`

The impermanence module does not include a function to wipe the non-persistent directories. This config uses btrfs subvolumes and wipes them using a script taken from the [impermanence repo](https://github.com/nix-community/impermanence?tab=readme-ov-file#btrfs-subvolumes). This has the advantage of keeping a handful of recently deleted roots as btrfs snapshots. If I forget to persist something and reboot, it can be recovered by mounting that snapshot. This method works for zfs as well but would need a different wiping script. GrahamC's blog linked above has one.

The other method is to use a tmpfs for `/`. This is simpler but uses more RAM and doesn't preserve the recently deleted root volumes.

## How to persist `/home`

 You have to decide how granular you want to be in persisting `/home`:
* You could persist all of `/home`. Cruft will accumulate in `~` and `.config` but you may be OK with that. This can be done by persisting home in the NixOS impermanence module or by having a separate subvolume for `/home` that doesn't get wiped at all.
* You could persist the main folders, like user data folders, `.config`, `.local`, and `.ssh`. This is a good middle ground.
* You could persist individual folders within `.config` and `.local`. You will have to comb through these folders and determine what you want to keep and throw away. Anything managed by home-manager should be declaratively symlinked to `/nix/store` and does not need to be persisted. Some applications spew a lot of loose files and folders in `.config` (looking at you, KDE), so this can be a bit fussy. If you have a lot application churn, you'll have to tweak this frequently. But the more you configure your system with home-manager, the less you will need to persist within `.config`.

My recommendation is to begin by persisting everything and gradually fine-tune it if you want. If something breaks, those files still exist in `/persist` and can be easily restored. If you're not sure where an application is storing its config or data, I include a `fs-diff` script which recursively lists all files in a directory, ignoring bind mounts and symlinks. By storing the output of this script in a file before and after making the change you're interested in, you can run a `diff` on those two files and see where that application is writing its change. I've found this especially useful for window manager files.

NB: If you are using the home-manager impermanence module, and intend to persist `~/.config`, do it through the **system** impermanence config, not home-manager. The bind mounts made by impermanence are done using systemd, which themselves live in `~/.config/systemd` for home-manager services. Home-manager **will fail** if you try to do this using its impermanence module. You probably don't need to persist `~/.config/systemd` itself though since its contents should be in your config.

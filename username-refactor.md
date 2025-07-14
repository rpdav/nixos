problem: need to enable multi-user support

current config makes use of userOpts.username to set a per-system default user. in hosts config:
* It's assigned in hosts/hostname/default.nix
* It's referenced in:
  * core config - nixos repo location
  * samba config (who's allowed to write) - currently onlu used for nas
  * ssh-unlock function to pull <user>/keys public keys
  * backup config - rename path of user ssh key to root's ssh key (to have access to backup root files)
  * virtualization and hyprland - add groups

in home config:
* used to reference home persistence directory in several modules
* git: assign username
* ssh: assign location for renamed manual ssh key
* sops: define location for user age key
* yubikey: assign location for sops ssh key paths
* steam: point to user directory for some stuff in .config

since this is defined on the host, it can't really be overridden in individual home-manager configs currently.

this is referenceable in home manager as config.home-manager.users.ryan.

solutions:
1. get rid of it - just replace it with the actual name of the primary user. Less abstraction. Secondary user probably doesn't need nearly as much custom home-manager config. Most of the HM references to userOPts.username go away if that user is going to have their whole home directory persisted.

anything that is truly user-specific (say git username) can go into that user's config. This will spread some functionality out (rest of git config will be in common) but is probably the most straightforward.

2. use config.home.username within home-manager instead of userOpts. will still need to change nixos config. Probably move it into the user's `user/default.nix` file.

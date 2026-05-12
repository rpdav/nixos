All commands need to include `--extra-experimental-features "nix-command flakes pipe-operators"`

Reinstall commands:
```
# Clone repo
git clone https://github.com/rpdav/nixos

# Install
sudo nix --extra-experimental-features "nix-command flakes pipe-operators" run 'github:nix-community/disko/latest#disko-install' -- --flake .#zenbook --disk main /dev/nvme0n1
```

## Notes during reinstall
Add zenbook.nix home-manager file
Add disko-install pipe-operators option
Switch secrets to gitea?
Install command requires --disk main /dev/nvme0n1

With above changes, getting an out of memory error

## Notes from fw13 VM reinstall using zenbook host
Add zenbook.nix home-manager file
Add disko-install pipe-operators option
Has trouble pulling secrets from gitea - test on main machine
New command with native disko binary:
`sudo disko-install --flake github:rpdav/nixos?ref=63-fw13-reinstall#zenbook --option extra-experimental-features pipe-operators --disk main /dev/vda`
^-- this still leads to out-of-disk (memory) failures even on a 16GB VM with disko on the iso

All commands need to include `--extra-experimental-features "nix-command flakes pipe-operators"`

Reinstall commands:
```
# Clone repo
git clone https://github.com/rpdav/nixos

# Install
sudo nix --extra-experimental-features "nix-command flakes pipe-operators" run 'github:nix-community/disko/latest#disko-install' -- --flake .#zenbook --disk main /dev/nvme0n1
```

## Notes from fw13 VM reinstall using testvm host
Add testbox.nix home-manager file
Add disko-install pipe-operators option
Has trouble pulling secrets from gitea - test on main machine
New command with native disko binary:
`sudo disko-install --flake github:rpdav/nixos?ref=63-fw13-reinstall#testvm --option extra-experimental-features pipe-operators --disk main /dev/vda`
^-- this still leads to out-of-disk (memory) failures even on a 16GB VM with disko on the iso when installing full config

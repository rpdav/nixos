All commands need to include `--extra-experimental-features "nix-command flakes pipe-operators"`

Reinstall commands:
```
# Clone repo
git clone https://github.com/rpdav/nixos
or
git clone -b 63-fw13-reinstall https://github.com/rpdav/nixos



# Install
sudo nix --extra-experimental-features "nix-command flakes pipe-operators" run 'github:nix-community/disko/latest#disko-install' -- --flake .#zenbook --disk main /dev/nvme0n1
```

## Notes during reinstall
Add zenbook.nix home-manager file
Add disko-install pipe-operators option
Switch secrets to gitea?
Install command requires --disk main /dev/nvme0n1

With above changes, getting an out of memory error

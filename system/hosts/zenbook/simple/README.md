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
using disko-install leads to "no space on device" due to too much being downloaded to /nix on tmpfs.
using disko command for separate partitioning seems to work but you have to tweak the disko file (no extra args, no importing disko module):
`sudo nix --extra-experimental-features "nix-command flakes pipe-operators" run 'github:nix-community/disko/latest' -- --mode disko ./disko.nix`
then install with:
`sudo nixos-install --flake .#zenbook`
not sure if this would work with main flake - no way to pass pipe operators


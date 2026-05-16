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

## VM install trimmed-down host
Removed most optional modules and WM
Still got OOM error

## VM install with super-minimal host
Removed even more stuff, very minimal config
This worked!

## VM install with disko, then nixos-install
This worked fine for the super-minimal config, but the `disko` tool needs a standalone disk config; no custom options
In contrast, `disko-install` can use my flake and the shared
If I'm going to maintain a standalone disk config for reinstall of each host, plus the shared one 
Need to pass --no-root-password to installer since it is declared in the config

## Future setup
The options are:
1. Use `disko-install` for reinstall
  1. Will need to maintain a separate minimal system config that points to the same disk config as the normal `fw13` host
  2. Once rebooted, restore data and then nixos-rebuild to switch to main config with secrets, etc
  3. It's possible that if the OOM issue is fixed for `disko-install` that I could drop the minimal config and go straight to the main one
  4. It's also possible that actually reinstalling on bare metal with 32 GB of RAM (instead of 16 GB VM) won't run into this issue
2. Use `disko` and `nixos-install`
  1. Will need to maintain a standalone disk config since `disko` can't use the usual config with custom options
  2. Install is a bit more complex (2 commands instead of 1!)
  3. 

## Test on bare metal with extra hard disk
Still got OOM error when restoring full config with full 32 GB RAM

## VM testing with install host
Install and rebuild seemed to go fine
/nix was 25 GB after rebuild
Passwords don't seem to be working as expected - `hashedPasswordFile` is set (/run/secrets/...), but the file isn't there. So `password` is overridden, and the user has no password. This will prevent future rebuilds (including enabling secrets). Secrets should be set up while booted in the minimal environment with the temp password
This means `password` can be removed from theage1y9h8h2ug59kkshnv3cu7rpgtulmnp628zzm9qfqjmf3sekvpnawqj5krl3age1y9h8h2ug59kkshnv3cu7rpgtulmnp628zzm9qfqjmf3sekvpnawqj5krl3age1y9h8h2ug59kkshnv3cu7rpgtulmnp628zzm9qfqjmf3sekvpnawqj5krl3 main host config

## VM install with secrets setup
Secrets need to be copied to /persist/etc and /persist/home/ryan/.config...otherwise they get blown away on rollback
May also need to delete existing keys in /etc/ssh, otherwise symlinking might not work
Directory /run/secrets-for-users is not getting generated, which is where passwordHash is supposed to live. Not sure why.

## Test VM RAM limits
### Non-custom iso
8GB - fail
16GB - OK

### custom iso
4GB - fail
8GB - OK

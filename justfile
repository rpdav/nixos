# just is a command runner, Justfile is very similar to Makefile, but simpler.

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

switch:
  sudo nixos-rebuild switch --flake .

dry:
  sudo nixos-rebuild dry-build --flake . 

debug:
  sudo nixos-rebuild switch --flake . --show-trace --verbose

up:
  nix flake update

# Update specific input
# usage: make upp i=home-manager
upp input:
  nix flake update {{input}}

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  # remove all generations older than 14 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 14d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-older-than 14d

backup:
  sudo systemctl restart borgbackup-job-local.service

############################################################################
#
#  Nix commands for remote systems
#
############################################################################

testbox: 
  nixos-rebuild --flake .#testbox --target-host root@10.10.1.18 switch 

testbox-dry: 
  nixos-rebuild --flake .#testbox --target-host root@10.10.1.18 dry-build

testbox-boot:
  nixos-rebuild --flake .#testbox --target-host root@10.10.1.18 boot

testbox-debug: 
  nixos-rebuild --flake .#testbox --target-host root@10.10.18 switch --show-trace -v

testvm: 
  nixos-rebuild --flake .#testvm --target-host root@10.10.1.19 switch 

testvm-dry: 
  nixos-rebuild --flake .#testvm --target-host root@10.10.1.19 dry-build

testvm-boot:
  nixos-rebuild --flake .#testvm --target-host root@10.10.1.19 boot

testvm-debug: 
  nixos-rebuild --flake .#testvm --target-host root@10.10.1.19 switch --show-trace -v

pi: 
  nixos-rebuild --flake .#pi --target-host root@pi switch 

pi-dry: 
  nixos-rebuild --flake .#pi --target-host root@pi dry-build

pi-debug: 
  nixos-rebuild --flake .#pi --target-host root@pi switch --show-trace -v

vps: 
  nixos-rebuild --flake .#vps --target-host root@testbox switch 

vps-dry: 
  nixos-rebuild --flake .#vps --target-host root@testbox dry-build

vps-debug: 
  nixos-rebuild --flake .#vps --target-host root@testbox switch --show-trace -v

machines: testbox 

machines-debug: testbox-debug

machines-dry: testbox-dry

## Docker

[no-cd]
compose project output='docker-compose.nix':
  compose2nix -write_nix_setup=false -runtime docker -project={{project}} -output={{output}}


############################################################################
#
#  Nixos-anywhere commands
#
############################################################################

anywhere-test:
  nix run github:nix-community/nixos-anywhere -- --flake .#testvm --vm-test

anywhere-deploy:
  nix run github:nix-community/nixos-anywhere -- --flake .#testvm --generate-hardware-config nixos-generate-config ./hosts/testvm/hardware-configuration.nix root@10.10.1.19

############################################################################
#
#  Misc utilities
#
############################################################################

nsearch:
  nix run github:niksingh710/nsearch

search expression:
  grep -Rnw . -e {{expression}}

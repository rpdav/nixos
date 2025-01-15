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

############################################################################
#
#  Nix commands for remote systems
#
############################################################################

deploy host:
  nixos-rebuild --flake .#{{host}} --target-host root@{host}} switch

deploy-test:
  just deploy vps
  just deploy testvm

testbox: 
  nixos-rebuild --flake .#testbox --target-host root@testbox switch 

testbox-dry: 
  nixos-rebuild --flake .#testbox --target-host root@testbox dry-build

testbox-boot:
  nixos-rebuild --flake .#testbox --target-host root@testbox boot

testbox-debug: 
  nixos-rebuild --flake .#testbox --target-host root@testbox switch --show-trace -v

testvm: 
  nixos-rebuild --flake .#testvm --target-host root@testvm switch 

testvm-dry: 
  nixos-rebuild --flake .#testvm --target-host root@testvm dry-build

testvm-boot:
  nixos-rebuild --flake .#testvm --target-host root@testvm boot

testvm-debug: 
  nixos-rebuild --flake .#testvm --target-host root@testvm switch --show-trace -v

vps: 
  nixos-rebuild --flake .#vps --target-host root@vps switch 

vps-dry: 
  nixos-rebuild --flake .#vps --target-host root@vps dry-build

vps-boot:
  nixos-rebuild --flake .#vps --target-host root@vps boot

vps-debug: 
  nixos-rebuild --flake .#vps --target-host root@vps switch --show-trace -v

machines: testvm vps

machines-boot: testvm-boot vps-boot

machines-debug: testvm-debug vps-debug

############################################################################
#
#  ixos-anywhere commands
#
############################################################################

[no-cd]
anywhere-test host:
  nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --vm-test

[no-cd]
anywhere host:
  nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --extra-files ~/anywhere --generate-hardware-config nixos-generate-config ./hosts/{{host}}/hardware-configuration.nix root@{{host}}

############################################################################
#
#  Docker
#
############################################################################

[no-cd]
compose project output='docker-compose.nix':
  compose2nix -write_nix_setup=false -runtime docker -project={{project}} -output={{output}}

uptix:
  uptix

############################################################################
#
#  Backup
#
############################################################################

backup:
  sudo systemctl restart borgbackup-job-local.service

restore:
  -sudo mkdir /tmp/borg 
  sudo borg mount ssh://borg@10.10.1.17:2222/backup/fw13 /tmp/borg

############################################################################
#
#  Misc utilities
#
############################################################################

nsearch:
  nix run github:niksingh710/nsearch


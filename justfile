# just is a command runner, Justfile is very similar to Makefile, but simpler.

set positional-arguments

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

switch:
  sudo nixos-rebuild switch --flake .

cosmic:
  sudo nixos-rebuild switch --flake . --specialisation cosmic

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

build host:
  # separate build command to get the nice nixos-cli/nvd output
  # using -o flag to make a gc root and keep builds from being immediatley gc'd
  nixos apply /home/ryan/nixos/.#{{host}} -o ~/result-nas_{{datetime("%Y-%m-%d_%T")}}

deploy host:
  sudo tailscale up --reset && nixos-rebuild --flake /home/ryan/nixos/.#{{host}} --target-host root@{{host}} switch; sudo tailscale up --accept-routes

############################################################################
#
#  nixos-anywhere commands
#
############################################################################

[no-cd]
anywhere-test host:
  nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --vm-test

[no-cd]
anywhere host ip:
  nix run github:nix-community/nixos-anywhere -- --flake .#{{host}} --extra-files ~/Documents/anywhere/{{host}} --generate-hardware-config nixos-generate-config ./hosts/{{host}}/hardware-configuration.nix root@{{ip}}

############################################################################
#
#  Docker
#
############################################################################

[no-cd]
compose project output='docker-compose.nix':
  nix run github:aksiksi/compose2nix -- -write_nix_setup=false -runtime docker -project={{project}} -output={{output}}

uptix:
  nix run github:luizribeiro/uptix

############################################################################
#
#  Backup
#
############################################################################

backup:
  sudo systemctl restart borgbackup-job-local.service

restore:
  -sudo mkdir /tmp/borg 
  sudo borg mount ssh://borg@borg:2222/backup/fw13 /tmp/borg

############################################################################
#
#  Misc utilities
#
############################################################################

shell program:
  nix shell nixpkgs#{{program}}

run program:
  nix run nixpkgs#{{program}}

search package:
  nix search nixpkgs {{package}}

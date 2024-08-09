# just is a command runner, Justfile is very similar to Makefile, but simpler.

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

switch:
  sudo nixos-rebuild switch --flake .

dry:
  sudo nixos-rebuild dry-activate --flake . 

debug:
  sudo nixos-rebuild switch --flake . --show-trace --verbose

up:
  nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
  nix flake update $(i)

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-older-than 30d

############################################################################
#
#  Nix commands for remote systems
#
############################################################################

nixos-vm: 
  sudo nixos-rebuild --flake .#nixos-vm --target-host root@nixos-vm switch 

nixos-vm-dry: 
  sudo nixos-rebuild --flake .#nixos-vm --target-host root@nixos-vm dry-activate

nixos-vm-debug: 
  sudo nixos-rebuild --flake .#nixos-vm --target-host root@nixos-vm switch --show-trace -v

pi: 
  sudo nixos-rebuild --flake .#pi --target-host root@pi switch 

pi-dry: 
  sudo nixos-rebuild --flake .#pi --target-host root@pi dry-activate

pi-debug: 
  sudo nixos-rebuild --flake .#pi --target-host root@pi switch --show-trace -v

vps: 
  sudo nixos-rebuild --flake .#vps --target-host root@nixos-vm switch 

vps-dry: 
  sudo nixos-rebuild --flake .#vps --target-host root@nixos-vm dry-activate

vps-debug: 
  sudo nixos-rebuild --flake .#vps --target-host root@nixos-vm switch --show-trace -v

machines: nixos-vm 

machines-debug: nixos-vm-debug

machines-dry: nixos-vm-dry


############################################################################
#
#  Nixos-anywhere commands
#
############################################################################

anywhere-test:
  nix run github:nix-community/nixos-anywhere -- --flake .#nixos-vm --vm-test

anywhere-deploy:
  nix run github:nix-community/nixos-anywhere -- --flake .#nixos-vm root@ubuntu

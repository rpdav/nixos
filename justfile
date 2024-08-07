# just is a command runner, Justfile is very similar to Makefile, but simpler.

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

deploy:
  nixos-rebuild switch --flake .

dry:
  nixos-rebuild switch --flake . --dry-run

debug:
  nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose

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
  nixos-rebuild --flake .#nixos-vm --target-host root@nixos-vm switch 

nixos-vm-dry: 
  nixos-rebuild --flake .#nixos-vm --target-host root@nixos-vm dry-activate

nixos-vm-debug: 
  nixos-rebuild --flake .#nixos-vm --target-host root@nixos-vm switch --show-trace -v

pi: 
  nixos-rebuild --flake .#pi --target-host root@pi switch 

pi-dry: 
  nixos-rebuild --flake .#pi --target-host root@pi dry-activate

pi-debug: 
  nixos-rebuild --flake .#pi --target-host root@pi switch --show-trace -v

vps: 
  nixos-rebuild --flake .#vps --target-host root@nixos-vm switch 

vps-dry: 
  nixos-rebuild --flake .#vps --target-host root@nixos-vm dry-activate

vps-debug: 
  nixos-rebuild --flake .#vps --target-host root@nixos-vm switch --show-trace -v

machines: nixos-vm 

machines-debug: nixos-vm-debug

machines-dry: nixos-vm-dry

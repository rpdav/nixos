{ config, userSettings, systemSettings, ... }:

{
## This file contains NixOS configuration common to all hosts

  imports = [
    ./tailscale.nix
    ./packages.nix
    ./sops.nix
    ./sshd.nix #needed for sops keys
  ];

## Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

## CLI config
  services.nixos-cli.enable = true;
  programs.bash.completion.enable = true;

## Time
  time.timeZone = systemSettings.timezone;

}

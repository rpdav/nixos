{ config, userSettings, systemSettings, ... }:

{
  imports = [
    ./tailscale.nix
    ./packages.nix
  ];


## CLI config
  services.nixos-cli.enable = true;
  programs.bash.completion.enable = true;

## Time
  time.timeZone = "systemSettings.timezone";

}

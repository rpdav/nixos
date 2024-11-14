{ config, userSettings, systemSettings, ... }:

{
  imports = [
    ./tailscale.nix
    ./packages.nix
  ];

## User definitions
  users.mutableUsers = false;
  sops.secrets."${userSettings.username}/passwordhash".neededForUsers = true;

  users.users.${userSettings.username} = {
    hashedPasswordFile = config.sops.secrets."${userSettings.username}/passwordhash".path;
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

## CLI config
  services.nixos-cli.enable = true;
  programs.bash.completion.enable = true;

## Time
  time.timeZone = "systemSettings.timezone";

}

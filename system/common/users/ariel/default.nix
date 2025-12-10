{
  config,
  inputs,
  secrets,
  pkgs-stable,
  pkgs-unstable,
  configLib,
  ...
}:
## This file contains all NixOS config for user ariel
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # user--specific variable overrides
  userOpts.theme = "mountain";
  userOpts.cursor = "Bibata-Modern-Ice";
  userOpts.cursorPkg = "bibata-cursors";

  # user definition
  users.mutableUsers = false;
  sops.secrets."passwordHashAriel" = {
    neededForUsers = true;
    sopsFile = "${inputs.nix-secrets.outPath}/ariel.yaml";
  };

  users.users.ariel = {
    hashedPasswordFile = config.sops.secrets."passwordHashAriel".path;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    home = "/home/ariel";
  };

  # home-manager config
  home-manager = {
    useUserPackages = true;
    users.ariel = import (configLib.relativeToRoot "home/ariel/${config.networking.hostName}.nix");
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit pkgs-unstable;
      inherit secrets;
      inherit inputs;
      inherit configLib;
    };
  };

  # Fix file permissions after backup restore
  #TODO make this work for non-persist systems too
  systemd.tmpfiles.rules = [
    # make all files in home directory owned by user
    "Z ${config.systemOpts.persistVol}/home/ariel - ariel users"
    # make user's home directory not readable by others
    "z ${config.systemOpts.persistVol}/home/ariel 0700 ariel users"
  ];
}

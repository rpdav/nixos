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
  userOpts.wallpaper = "mountain";
  userOpts.cursor = "Bibata-Modern-Ice";
  userOpts.cursorPkg = "bibata-cursors";

  # user definition
  users.mutableUsers = false;
  sops.secrets."ariel/passwordhash".neededForUsers = true;

  users.users.ariel = {
    hashedPasswordFile = config.sops.secrets."ariel/passwordhash".path;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    home = "/home/ariel";
  };

  # home-manager config
  home-manager = {
    useUserPackages = true;
    users.ariel = import (configLib.relativeToRoot "home/ariel/${config.networking.hostName}.nix");
    sharedModules = [
      (import (configLib.relativeToRoot "modules/home-manager"))
    ];
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
    "Z ${config.systemOpts.persistVol}/home/ariel 0700 ariel users"
  ];
}

{
  config,
  lib,
  inputs,
  secrets,
  systemOpts,
  pkgs-stable,
  pkgs-unstable,
  configLib,
  ...
}:
## This file contains all NixOS config for user ryan
let
  # Generates a list of the keys in ./keys
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in {
  # user--specific variable overrides
  userOpts.wallpaper = "moon";
  userOpts.base16scheme = "catppuccin-mocha";
  userOpts.cursor = "Bibata-Modern-Ice";
  userOpts.cursorPkg = "bibata-cursors";

  # user definition
  users.mutableUsers = false;
  sops.secrets."ryan/passwordhash".neededForUsers = true;

  users.users.ryan = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    home = "/home/ryan";

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos hosts
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # home-manager config
  home-manager = {
    useUserPackages = true;
    users.ryan = import (configLib.relativeToRoot "home/ryan/${config.networking.hostName}.nix");
    sharedModules = [
      (import (configLib.relativeToRoot "modules/home-manager"))
    ];
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit pkgs-unstable;
      inherit secrets;
      inherit inputs;
      inherit configLib;
      # Pass custom options assigned in nixos module to HM
      systemOpts = config.systemOpts;
      userOpts = config.userOpts;
      serviceOpts = config.serviceOpts;
    };
  };

  # Fix file permissions after backup restore
  #TODO make this work for non-persist systems too
  systemd.tmpfiles.rules = [
    "Z ${systemOpts.persistVol}/home/ryan - ryan users"
  ];
}

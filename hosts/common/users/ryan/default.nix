{
  config,
  lib,
  inputs,
  secrets,
  pkgs-stable,
  configLib,
  ...
}:
## This file contains all NixOS config for user ryan
let
  # Generates a list of the keys in ./keys
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in {
  imports = [
    # This uses unstable HM for all systems (including stable ones).
    # The stable ones are all headless so not a lot of risk in things breaking.
    inputs.home-manager-unstable.nixosModules.home-manager
  ];

  # user--specific variable overrides
  userSettings.wallpaper = "moon";
  userSettings.base16scheme = "catppuccin-mocha";
  userSettings.cursor = "Bibata-Modern-Ice";
  userSettings.cursorPkg = "bibata-cursors";

  # user definition
  users.mutableUsers = false;
  sops.secrets."ryan/passwordhash".neededForUsers = true;

  users.users.ryan = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    home = "/home/ryan"; # Setting this to point local backup to persisted home directory. Not sure this will actually work

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos hosts
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # home-manager config
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ryan = import (configLib.relativeToRoot "home/ryan/${config.networking.hostName}.nix");
    sharedModules = [
      (import (configLib.relativeToRoot "modules/home-manager"))
    ];
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit secrets;
      inherit inputs;
      inherit configLib;
    };
  };

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
  };
}

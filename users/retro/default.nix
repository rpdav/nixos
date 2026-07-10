{
  inputs,
  self,
  ...
}: {
  # This is a generic user-definition module which creates a user,
  # declares a password, and creates a home-manager environment.
  # Update the module name `flake.nixosModules.user-foo` and
  # let binding `user = "foo";` to make changes throughout.
  flake.nixosModules.user-retro = {
    config,
    lib,
    ...
  }: let
    user = "retro";
    # Derive capitalized user "Foo" (for camel case usage) from user "foo"
    User = (lib.toUpper (builtins.substring 0 1 user)) + (builtins.substring 1 (builtins.stringLength user) user);
  in {
    ## This file contains all NixOS config for user retro

    # user--specific variable overrides
    userOpts.theme = "retroarch";
    userOpts.cursor = "Bibata-Modern-Ice";
    userOpts.cursorPkg = "bibata-cursors";

    # user definition
    # this is an unprivileged kiosk account
    users.mutableUsers = false;
    sops.secrets."passwordHash${User}" = {
      neededForUsers = true;
      sopsFile = "${inputs.nix-secrets.outPath}/${user}.yaml";
    };
    users.users.${user} = {
      hashedPasswordFile = config.sops.secrets."passwordHash${User}".path;
      isNormalUser = true;
      home = "/home/${user}";
    };

    # home-manager config
    home-manager.users.${user} = {
      home.username = user;
      imports = [self.homeModules."${user}@${config.networking.hostName}"];
    };

    # Fix file permissions after backup restore
    systemd.tmpfiles.rules = [
      # make all files in home directory owned by user
      "Z ${config.systemOpts.persistVol}/home/${user} - ${user} users"
      # make user's home directory not readable by others
      "z ${config.systemOpts.persistVol}/home/${user} 0700 ${user} users"
    ];
  };
}

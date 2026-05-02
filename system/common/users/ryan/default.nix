{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  secrets,
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
  imports = [
    inputs.nixos-cli.nixosModules.nixos-cli
    inputs.home-manager.nixosModules.home-manager
  ];

  # user--specific variable overrides
  userOpts.theme = "astronaut";
  userOpts.cursor = "Bibata-Modern-Ice";
  userOpts.cursorPkg = "bibata-cursors";

  # user definition
  users.mutableUsers = false;
  sops.secrets."passwordHashRyan" = {
    neededForUsers = true;
    sopsFile = "${inputs.nix-secrets.outPath}/ryan.yaml";
  };

  users.users.ryan = {
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    home = "/home/ryan";

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos hosts
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # Options search and nixos CLI tooling
  programs.nixos-cli = {
    enable = true;
    settings = {
      config_location = "${config.users.users.ryan.home}/nixos";
      differ.command = [
        "nvd"
        "diff"
      ];
      apply = {
        use_git_commit_msg = true;
        use_nom = true;
        reexec_as_root = true;
      };
      ssh.known_hosts_files = [
        (lib.mkIf config.systemOpts.impermanent "${config.systemOpts.persistVol}/home/ryan/.ssh/known_hosts")
      ];
    };
  };
  nix.settings = {
    substituters = ["https://watersucks.cachix.org"];
    trusted-public-keys = [
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
    ];
  };
  environment.systemPackages = [pkgs.nvd];

  # home-manager config
  home-manager = {
    #useUserPackages = true;
    users.ryan = import (configLib.relativeToRoot "home/ryan/${config.networking.hostName}.nix");
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit pkgs-unstable;
      inherit secrets;
      inherit inputs;
      inherit outputs;
      inherit configLib;
    };
  };

  # Fix file permissions after backup restore
  #TODO make this work for non-persist systems too
  systemd.tmpfiles.rules = [
    # make all files in home directory owned by user
    "Z ${config.systemOpts.persistVol}/home/ryan - ryan users"
    # make user's home directory not readable by others
    "z ${config.systemOpts.persistVol}/home/ryan 0700 ryan users"
  ];
}

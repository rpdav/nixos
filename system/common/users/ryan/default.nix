{...}: {
  flake.nixosModules.userRyan = {
    config,
    lib,
    pkgs,
    inputs,
    self,
    ...
  }:
  ## This file contains all NixOS config for user ryan
  {
    imports = [
      inputs.nixos-cli.nixosModules.nixos-cli
      inputs.home-manager.nixosModules.home-manager
    ];

    # user--specific variable overrides
    userOpts.theme = "rainbow-cat";
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
      openssh.authorizedKeys.keyFiles = lib.filesystem.listFilesRecursive ./keys;
    };

    # Options search and nixos CLI tooling #TODO move this to admin module
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
    environment.systemPackages = [
      pkgs.nvd # diffing tool
    ];

    # home-manager config
    home-manager = {
      users.ryan = self.homeModules."ryan@${config.networking.hostName}";
      extraSpecialArgs = {
        inherit inputs self;
      };
    };

    # Fix file permissions after backup restore
    systemd.tmpfiles.rules = [
      # make all files in home directory owned by user
      "Z ${config.systemOpts.persistVol}/home/ryan - ryan users"
      # make user's home directory not readable by others
      "z ${config.systemOpts.persistVol}/home/ryan 0700 ryan users"
    ];
  };
}

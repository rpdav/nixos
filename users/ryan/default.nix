{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.user-ryan = {
    config,
    lib,
    ...
  }: {
    ## This file contains all NixOS config for user ryan
    imports = [self.nixosModules.admin];

    # user--specific variable overrides
    userOpts.theme = "astronaut";
    userOpts.cursor = "Bibata-Modern-Ice";
    userOpts.cursorPkg = "bibata-cursors";

    # Pull secrets from sops
    users.mutableUsers = false;
    sops.secrets."passwordHashRyan" = {
      neededForUsers = true;
      sopsFile = "${inputs.nix-secrets.outPath}/ryan.yaml";
    };

    # user definition
    users.users.ryan = {
      hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
      isNormalUser = true;
      extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
      home = "/home/ryan";
      openssh.authorizedKeys.keyFiles = lib.filesystem.listFilesRecursive ./keys;
    };

    # home-manager config
    home-manager = {
      users.ryan = self.homeModules."ryan@${config.networking.hostName}";
    };

    # Fix file permissions after backup restore
    systemd.tmpfiles.rules = [
      # make all files in home directory owned by user
      "Z ${config.systemOpts.persistVol}/home/ryan - ryan users"
      # make user's home directory not readable by others
      "z ${config.systemOpts.persistVol}/home/ryan 0700 ryan users"
    ];
  };
  flake.homeModules.user-ryan = {...}: {
    home.username = "ryan";
  };
}

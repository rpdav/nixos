{inputs, ...}: {
  flake.nixosModules.core = {
    config,
    pkgs,
    ...
  }:
  # This module uses sshd keys to generate host age keys - sshd must be enabled for system-level sops to work
  let
    inherit (config) systemOpts;
    # Define appropriate key path depending on whether system is impermanent
    defaultPath = "/etc/ssh/ssh_host_ed25519_key";
    sshKeyPaths =
      if systemOpts.impermanent
      then ["${systemOpts.persistVol}/${defaultPath}"]
      else [defaultPath];
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    environment.systemPackages = [pkgs.sops];

    sops = {
      defaultSopsFile = "${inputs.nix-secrets.outPath}/${config.networking.hostName}.yaml";
      defaultSopsFormat = "yaml";
      age = {
        # Automatically import ssh keys as age keys
        inherit sshKeyPaths;
        # generate age key from ssh key if not already present
        generateKey = true;
      };
    };
  };
  flake.homeModules.core = {
    config,
    osConfig,
    lib,
    ...
  }: let
    homeDir = config.home.homeDirectory;
    persistVol = osConfig.systemOpts.persistVol;
    impermanent = osConfig.systemOpts.impermanent;
    # Define appropriate key path depending on whether system is impermanent
    keyLocation = "${homeDir}/.config/sops/age/keys.txt";
    keyFile =
      if impermanent
      then "${persistVol}${keyLocation}"
      else "${keyLocation}";
  in {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    # Create persistent directories
    home.persistence."${persistVol}" = lib.mkIf config.userOpts.impermanent {
      directories = [
        ".config/sops"
      ];
    };

    sops = {
      defaultSopsFile = "${inputs.nix-secrets.outPath}/${config.home.username}.yaml";
      defaultSopsFormat = "yaml";
      age = {
        inherit keyFile;
      };
    };
  };
}

{inputs, ...}: {
  flake.nixosModules.core = {
    config,
    pkgs,
    ...
  }:
  # This module uses sshd keys to generate host age keys - sshd must be enabled for system-level sops to work
  let
    inherit (config) systemOpts;
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    environment.systemPackages = [pkgs.sops];

    sops = {
      defaultSopsFile = "${inputs.nix-secrets.outPath}/${config.networking.hostName}.yaml";
      defaultSopsFormat = "yaml";
      age = {
        # Automatically import ssh keys as age keys
        sshKeyPaths = ["${systemOpts.persistVol}/etc/ssh/ssh_host_ed25519_key"];
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
    persistVol = osConfig.systemOpts.persistVol;
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
      age.keyFile = "${persistVol}${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}

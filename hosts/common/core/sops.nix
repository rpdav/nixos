{
  inputs,
  config,
  pkgs,
  ...
}:
# This module uses sshd keys to generate host age keys - sshd must be enabled for system-level sops to work
let
  inherit (config) systemOpts;
  secretspath = builtins.toString inputs.nix-secrets;

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
    defaultSopsFile = "${secretspath}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age = {
      # Automatically import ssh keys as age keys
      inherit sshKeyPaths;
      # generate age key from ssh key if not already present
      generateKey = true;
    };
  };
}

{
  inputs,
  systemOpts,
  pkgs,
  ...
}:
# This module uses sshd keys to generate host age keys - sshd must be enabled for system-level sops to work
let
  secretspath = builtins.toString inputs.nix-secrets;

  # Define appropriate key path depending on whether system is impermanent
  sshKeyPaths =
    if systemOpts.impermanent
    then ["/persist/etc/ssh/ssh_host_ed25519_key"]
    else ["/etc/ssh/ssh_host_ed25519_key"];
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = [pkgs.sops];

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age = {
      # Automatically import ssh keys as age keys
      inherit sshKeyPaths;
      # specified location for age key
      keyFile = "/var/lib/sops-nix/key.txt";
      # generate age key from ssh key if not already present
      generateKey = true;
    };
  };
}

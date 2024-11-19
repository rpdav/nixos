{ inputs, config, ... }:

# This module uses sshd keys to generate host age keys - sshd must be enabled for system-level sops to work

let 
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml"; 
    defaultSopsFormat = "yaml";
    age = {
      # Automatically import ssh keys as age keys
      # Must be in persistent volume if using impermanence
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      # specified location for age key
      keyFile = "/var/lib/sops-nix/key.txt";
      # generate age key from ssh key if not already present
      generateKey = true;
    };
  };
}

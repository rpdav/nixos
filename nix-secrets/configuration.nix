# This is an example of what a system configuration file could look like
# This would live in the main repo, not the secrets repo
{
  config,
  inputs,
  pkgs,
  ...
}: let
  # Define appropriate key path depending on whether system is impermanent
  # Secrets decryption happens before impermanent directories are mounted,
  # so this must be the actual location.
  # This let binding is unnecessary if your ssh keys are always in one location
  defaultPath = "/etc/ssh/ssh_host_ed25519_key";
  sshKeyPaths =
    if config.systemOpts.impermanent
    then ["${config.systemOpts.persistVol}/${defaultPath}"]
    else [defaultPath];
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  # Tools for generating keys and encrypting/decrypting secrets
  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
  ];

  sops = {
    # Default sops file is the system-specific one. This assumes machine1 is the hostname of the machine.
    defaultSopsFile = "${inputs.nix-secrets.outPath}/${config.networking.hostName}.yaml";
    defaultSopsFormat = "yaml";
    age = {
      # Define where ssh keys live
      inherit sshKeyPaths;
      # generate age key from ssh key. This gets placed at /run/secrets.d
      generateKey = true;
    };
  };

  # Declaring sops.secrets
  sops.secrets = {
    # Enable a secret from common.yaml
    "borg/passphrase" = {
      sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
    };
    # Enable a secret from machine1.yaml.
    # No need to declare sopsFile since machine1.yaml is set as default
    # Calling the secret with an empty set is all that's needed for sops to decrypt it.
    "machine1-service/apiKey" = {};
    # Enable a system secret from user1.yaml
    # If multiple users are defined, they must have unique passwordHash keys
    passwordHashUser1 = {
      neededForUsers = true; # this must be set to use sops-nix for user password management.
      sopsFile = "${inputs.nix-secrets.outPath}/user1.yaml";
    };
  };

  users.users.user1 = {
    hashedPasswordFile = config.sops.secrets."passwordHashUser1".path;
  };

  services.machine1-service = {
    # Point this service to the location where the unencrypted secret lives. By default this is in /run/secrets.
    apiKeyLocation = config.sops.secrets."machine1-service/apiKey".path;
  };
}

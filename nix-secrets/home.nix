# This is an example of a home-manager configuration using this sops repo.
# This would live in the main repo, not the
{
  inputs,
  secrets,
  config,
  osConfig,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
  persistVol = osConfig.systemOpts.persistVol;
  impermanent = osConfig.systemOpts.impermanent;
  # Define appropriate key path depending on whether system is impermanent
  # Secrets decryption happens before impermanent directories are mounted,
  # so this must be the actual location.
  keyLocation = "${homeDir}/.config/sops/age/keys.txt";
  keyFile =
    if impermanent
    then "${persistVol}${keyLocation}"
    else "${keyLocation}";
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    # Default sops file is the user-specific one. Assumes uername is user1
    defaultSopsFile = "${inputs.nix-secrets.outPath}/${config.home.username}.yaml";
    defaultSopsFormat = "yaml";
    age = {
      # inherit where keyfiles are defined in let binding above
      inherit keyFile;
    };
  };
  sops.secrets = {
    # copy ssh key into home ssh folder
    "sshKeys/id_ed25519".path = "${homeDir}/.ssh/id_ed25519";
    # decrypt borg ssh key. This is user-specific so it comes from default user1.yaml file.
    # not putting it in .ssh since it isn't used for routine ssh sessions.
    "sshKeys/id_borg" = {};
    # borg passphrase comes from common.yaml since it's shared between systems/users.
    "borg/passphrase" = {
      sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
    };
    "email/personal-mail/password" = {};
  };
  accounts.email.accounts = {
    personal = {
      # email address can't be pulled from sops since it wants the actual value, not a command or path. Using secrets input from flake.nix.
      address = secrets.user1.email.personal-mail.address;
      passwordCommand = "cat ${config.sops.secrets."email/personal-mail/password".path}";
    };
  };
}

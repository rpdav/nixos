{
  inputs,
  userOpts,
  systemOpts,
  lib,
  ...
}: let
  secretspath = builtins.toString inputs.nix-secrets;

  # Define appropriate key path depending on whether system is impermanent
  keyLocation = "/home/${userOpts.username}/.config/sops/age/keys.txt";
  keyFile =
    if systemOpts.impermanent
    then "${systemOpts.persistVol}/${keyLocation}"
    else "${keyLocation}";
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  # Create impermanent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".config/sops"
    ];
  };

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age = {
      inherit keyFile;
    };
  };
}

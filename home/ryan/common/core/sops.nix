{
  inputs,
  config,
  osConfig,
  lib,
  ...
}: let
  secretspath = builtins.toString inputs.nix-secrets;
  homeDir = config.home.homeDirectory;
  persistVol = osConfig.systemOpts.persistVol;
  impermanent = osConfig.systemOpts.impermanent;
  # Define appropriate key path depending on whether system is impermanent
  keyLocation = "${homeDir}/.config/sops/age/keys.txt";
  keyFile =
    if impermanent
    then "${persistVol}/${keyLocation}"
    else "${keyLocation}";
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  # Create impermanent directories
  home.persistence."${persistVol}${homeDir}" = lib.mkIf impermanent {
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

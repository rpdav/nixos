{
  inputs,
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
  home.persistence."${persistVol}${homeDir}" = lib.mkIf config.userOpts.impermanent {
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
}

{ inputs, userSettings, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;   
    defaultSopsFormat = "yaml";
    age.keyFile = "/persist/home/${userSettings.username}/.config/sops/age/keys.txt";
  };
}

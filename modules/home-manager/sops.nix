{ inputs, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;   
    defaultSopsFormat = "yaml";
    age.keyFile = "~/.config/sops/age/keys.txt";
  };
}

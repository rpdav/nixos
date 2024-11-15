{ inputs, userSettings, ... }:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml"; 
    defaultSopsFormat = "yaml";
    age.keyFile = "/persist/home/${userSettings.username}/.config/sops/age/keys.txt";
  };
}

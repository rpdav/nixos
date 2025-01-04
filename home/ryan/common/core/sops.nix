{
  inputs,
  userOpts,
  ...
}: let
  secretspath = builtins.toString inputs.nix-secrets;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "/persist/home/${userOpts.username}/.config/sops/age/keys.txt";
  };
}

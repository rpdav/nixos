{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./rollback.nix
    ./persist.nix
  ];
}

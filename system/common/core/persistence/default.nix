{...}: {
  #TODO remove after import-tree
  imports = [
    ./rollback.nix
    ./persist.nix
  ];
  flake.nixosModules.core = {inputs, ...}: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];
  };
}

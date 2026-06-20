{inputs, ...}: {
  #TODO remove after import-tree
  imports = [
    ./rollback.nix
    ./persist.nix
  ];
  flake.nixosModules.core = {...}: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];
  };
}

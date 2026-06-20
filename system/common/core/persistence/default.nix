{inputs, ...}: {
  flake.nixosModules.core = {...}: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];
  };
}

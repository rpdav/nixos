{inputs, ...}: {
  imports = [inputs.home-manager.flakeModules.home-manager]; # needed to merge modules
  flake.nixosModules.home-manager = {...}: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager = {
      useUserPackages = false;
      useGlobalPkgs = false;
    };
  };
}

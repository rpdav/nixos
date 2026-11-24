{inputs, ...}: {
  imports = [inputs.home-manager.flakeModules.home-manager]; # needed to merge modules
  flake.nixosModules.homeManager = {pkgs-stable, ...}: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit pkgs-stable;
      };
    };
  };
}

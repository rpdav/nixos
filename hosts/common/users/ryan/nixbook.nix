{config, inputs, secrets, pkgs-stable, ...}:
{

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ryan = import ../../../../home/ryan/nixbook.nix;
    sharedModules = with inputs; [ 
      plasma-manager.homeManagerModules.plasma-manager 
      impermanence.nixosModules.home-manager.impermanence
    ];
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit secrets;
      inherit inputs;
    };
  };
}

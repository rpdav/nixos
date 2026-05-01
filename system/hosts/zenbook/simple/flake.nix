{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
      modules = [./configuration.nix];
    };
  };
}

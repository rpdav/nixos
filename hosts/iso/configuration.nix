{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-iso];
  };
  flake.nixosModules.system-iso = {
    pkgs,
    modulesPath,
    ...
  }: let
    install = pkgs.writeShellScriptBin "install" ''
      sudo disko-install \
      --option extra-experimental-features pipe-operators \
      --write-efi-boot-entries \
      --flake "github:rpdav/nixos#install" \
      --disk main $1
    '';
  in {
    imports = [
      "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    environment.systemPackages = [
      pkgs.disko
      install
    ];
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };
}

{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.admin = {
    lib,
    config,
    pkgs,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    imports = [
      inputs.nixos-cli.nixosModules.nixos-cli
      (inputs.uptix.nixosModules.uptix "${self}/uptix.lock") # point uptix to root of repo for lock file
    ];

    # Options search and nixos CLI tooling
    programs.nixos-cli = {
      enable = true;
      settings = {
        config_location = "${config.users.users.ryan.home}/nixos";
        differ.command = [
          "nvd"
          "diff"
        ];
        apply = {
          use_git_commit_msg = true;
          use_nom = true;
          reexec_as_root = true;
        };
        ssh.known_hosts_files = [
          (lib.mkIf config.systemOpts.impermanent "${config.systemOpts.persistVol}/home/ryan/.ssh/known_hosts")
        ];
      };
    };

    environment.systemPackages =
      [
        # diffing tool
        pkgs.nvd

        # nix file conversion tools
        selfpkgs.json2nix
        selfpkgs.nix2json
        selfpkgs.nix2toml
        selfpkgs.nix2yaml
        selfpkgs.toml2nix
        selfpkgs.yaml2nix

        # convenience script for nix-search-tv
        selfpkgs.nix-search-tv

        # misc
        selfpkgs.fs-diff

        # docker scripts
        selfpkgs.dup
        selfpkgs.ddown
        selfpkgs.dcup
        selfpkgs.dcdown
        selfpkgs.dtail
        selfpkgs.dexec
        selfpkgs.dclist
        selfpkgs.dcupall
        selfpkgs.dcdownall
      ]
      ++ (with pkgs; [
        # docker container management tools
        inputs.uptix.packages.${stdenv.hostPlatform.system}.uptix
        oxker
        lazydocker
      ]);

    home-manager.users.ryan.programs.lazydocker = {
      enable = true;
      settings = {
        gui.returnImmediately = true;
      };
    };
  };
}

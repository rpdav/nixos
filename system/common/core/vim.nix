{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.nvf.nixosModules.default];

  environment.systemPackages = [pkgs.wl-clipboard];

  nix.settings = {
    substituters = ["https://nvf.cachix.org"];
    trusted-public-keys = ["nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="];
  };

  # enable for all x86_64-linux hosts
  programs.nvf =
    lib.mkIf (
      config.nixpkgs.hostPlatform.system
      != "aarch64-linux"
    ) {
      enable = true;
      settings = {
        vim = {
          vimAlias = true;
          viAlias = false;
          globals.mapleader = "\\";
          statusline.lualine.enable = true;
          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;
          options = {
            mouse = "a";
            number = true;
            relativenumber = true;
            shiftwidth = 2;
            si = true;
          };
          lsp = {
            enable = true;
            formatOnSave = true;
            mappings.format = "<leader>f";
          };
          languages = {
            enableTreesitter = true;
            nix = {
              enable = true;
              lsp.servers = ["nixd"];
              format.enable = true;
            };
            markdown.enable = true;
          };
        };
      };
    };
}

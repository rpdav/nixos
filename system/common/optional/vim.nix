{...}: {
  flake.nixosModules.vim = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.nvf.nixosModules.default];

    environment.systemPackages = [pkgs.wl-clipboard];

    # enable for all x86_64-linux hosts
    programs.nvf = {
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
  };
}

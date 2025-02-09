{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nvf.nixosModules.default];

  environment.systemPackages = [pkgs.wl-clipboard];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        #TODO tie this into stylix somehow?
        theme = {
          enable = true;
          transparent = true;
          name = "catppuccin";
          style = "mocha";
        };
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
          formatOnSave = true;
          mappings.format = "<leader>f";
        };
        languages = {
          enableLSP = true;
          enableTreesitter = true;
          nix = {
            enable = true;
            format.enable = true;
          };
          markdown.enable = true;
        };
      };
    };
  };
}

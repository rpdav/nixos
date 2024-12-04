{
  pkgs,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "neovim";
  };

  programs.vim = {
    enable = true;
    settings = {
      mouse = "a";
      number = true;
      relativenumber = true;
      tabstop = 2;
    };
    plugins = [pkgs.vimPlugins.vim-nix pkgs.vimPlugins.vim-just];
    extraConfig = ''
      set autoindent
      set smartindent
    '';
  };

#  programs.neovim = {
#    enable = true;
#  };
#  home.file.init = {
#    source = ./nvim;
#    target = ".config/nvim";
#  };

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      lsp.enable = true;
      lsp.servers = {
	      nixd.enable = true;
        lua-ls.enable = true;
      };
    };
    opts = {
      mouse = "a";
      number = true;
      relativenumber = true;
#      softtabstop = 2;
      shiftwidth = 2;
      ai = true;
      si = true;
    };
  };
}

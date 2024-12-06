{
  pkgs,
  userSettings,
  ...
}: 

let
  flake = "(builtins.getFlake \"/home/${userSettings.username})\"";
in
{
  imports = [ ./cmp.nix ];
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
      set smartindent
    '';
  };

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    colorschemes.catppuccin.enable = true;
    globals.mapleader = " ";
    plugins = {
      lualine.enable = true;
      lsp.enable = true;
      lsp.servers = {
	nixd = {
	  enable = true;
	  settings = {
	    formatting.command = [ "alejandra" ];
	    nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
	    options =
	      {
	        # Completitions for nixos options
		#TODO make this host-generic
	        nixos.expr = "${flake}.nixosConfigurations.fw13.options.programs.nixvim.type.getSubOptions []";
	      };
	  };
	};
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

{
  pkgs,
  userSettings,
  inputs,
  ...
}: let
  flake = "(builtins.getFlake \"/home/${userSettings.username})\"";
in {
  imports = [
    ./cmp.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

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
    plugins = {
      lualine.enable = true;
      lsp = {
        enable = true;
        keymaps.lspBuf = {
          f = "format";
        };
        servers = {
          nixd = {
            enable = true;
            settings = {
              formatting.command = ["alejandra"];
              nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
              # was not able to get completions from my own flake to work.
              # See https://github.com/vimjoyer/nix-editor-setup-video/issues/5#issuecomment-2468418719
              #options = {
              #  # Completitions for nixos options
              #  nixos.expr = "${flake}.nixosConfigurations.fw13.options.programs.nixvim.type.getSubOptions []";
              #};
            };
          };
          lua_ls.enable = true;
        };
      };
    };
    opts = {
      mouse = "a";
      number = true;
      relativenumber = true;
      #      softtabstop = 2;
      shiftwidth = 2;
      si = true;
    };
  };
}

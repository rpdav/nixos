{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "vim";
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
}

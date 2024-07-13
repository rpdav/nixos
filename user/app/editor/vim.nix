{ config, pkgs, ... }:

{

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
    extraConfig =
    ''
      set autoindent
      set smartindent
    '';
  };

}

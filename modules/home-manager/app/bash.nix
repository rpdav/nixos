{ config, pkgs, ... }:

{

  programs.bash.historyFile = "/persist/home/ryan/.bash_history";

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -la";
      ## git
      gs = "git status";
      gc = "git commit -am";
      gp = "git push";
    };
    bashrcExtra = ''
      force_color_prompt=yes
      PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '
    '';
  };

}

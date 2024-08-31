{ config, pkgs, ... }:

{

  programs.bash.historyFile = "/persist/home/ryan/.bash_history";

  programs.bash = {
    enable = true;
    enableCompletion = true;
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

  programs.starship = {
    enable = true;
    settings = {
      settings = pkgs.lib.importTOML ./starship.toml;
#      add_newline = true;
#      command_timeout = 1000;
#      format = "$username";
#      character = {
#        success_symbol = "[󰜃 ](bright-cyan)";
#        error_symbol = "[](red)";
#      };
#      username = {
#        style_user = "white";
#        style_root = "white";
#        format = "[$user]($style) ";
#        disabled = false;
#        show_always = true;
#      };
#      hostname = {
#        ssh_only = false;
#        format = "@ [$hostname](bold yellow) ";
#        disabled = false;
#      };
#      directory = {
#        home_symbol = "󰋞 ~";
#        read_only_style = "197";
#        read_only = "  ";
#        format = "at [$path]($style)[$read_only]($read_only_style) ";
#      };
#      git_branch = {
#        symbol = " ";
#        format = "via [$symbol$branch]($style) ";
#        style = "bold green";
#      };
#      git_status = {
#        format = "[\($all_status$ahead_behind\)]($style) ";
#        style = "bold green";
#        conflicted = "🏳";
#        up_to_date = " ";
#        untracked = " ";
#        ahead = "⇡\${count}";
#        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
#        behind = "⇣\${count}";
#        stashed = " ";
#        modified = " ";
#        staged = "[++\($count\)](green)";
#        renamed = "襁 ";
#        deleted = " ";
#      };
    };
  };

}

{...}: {
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

      ## docker
      dtail = "docker logs -tf --tail=\"50\" \"$@\"";
      dps = "docker ps";
    };
    bashrcExtra = ''
      # this is overridden if stylix is used
      force_color_prompt=yes
      PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '

      #Docker functions
      #TODO make these shell applications?
      function dcup() {
        docker compose -f /root/services/$1/docker-compose.yml up -d;
      }

      function dcdown() {
        docker compose -f /root/services/$1/docker-compose.yml stop;
      }

      function dcpull() {
        docker compose -f /root/services/$1/docker-compose.yml pull;
      }

      function dclogs() {
        docker compose -f /root/services/$1/docker-compose.yml logs -tf --tail="50";
      }

      function dprune() {
        docker image prune -af
      }

      function appdata() {
        cd /root/services/$1;
      }

      function dexec() {
        docker exec -it $1 /bin/bash;
      }
    '';
  };

  programs.autojump.enable = true;

  #  programs.starship = {
  #    enable = true;
  #    settings = {
  #      settings = pkgs.lib.importTOML ./starship.toml;
  #    };
  #  };
}

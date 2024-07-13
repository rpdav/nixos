{ config, pkgs, ... }:

{

  programs.bash.historyFile = "/persist/home/ryan/.bash_history";

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -la";
      ## nix commands
      nix-switch = "sudo nixos-rebuild switch --flake /home/ryan/.nixops";
      rebuild = "bash ~/scripts/rebuild.sh";
      fs-diff = "bash ~/scripts/fs-diff.sh";
      ## wireguard
      wgup = "bash ~/scripts/wgup.sh";
      wgdown = "bash ~/scripts/wgdown.sh";
    };
  };

}

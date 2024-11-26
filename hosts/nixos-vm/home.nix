{
  config,
  pkgs,
  pkgs-stable,
  impermanence,
  secrets,
  systemSettings,
  userSettings,
  ...
}: {
  imports = [
    ../../variables.nix
  ];
  home.username = "${userSettings.username}";
  home.homeDirectory = "/home/${userSettings.username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "ryan";
    userEmail = "${secrets.personal-mail.address}";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

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
      ## git
      gs = "git status";
      gc = "git commit -am";
      gp = "git push";
      ## wireguard
      wgup = "bash ~/scripts/wgup.sh";
      wgdown = "bash ~/scripts/wgdown.sh";
    };
  };

  home.packages = with pkgs; [
  ];
}

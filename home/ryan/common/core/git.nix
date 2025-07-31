{...}: {
  programs.git = {
    enable = true;
    userName = "ryan";
    userEmail = "105075689+rpdav@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      merge.ff = false; # I prefer to see explicit merges
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.autoFetch = false; # too many "yubikey waiting for touch" prompts
    };
  };
}

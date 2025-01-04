{userOpts, ...}: {
  programs.git = {
    enable = true;
    userName = userOpts.username;
    userEmail = userOpts.githubEmail;
    extraConfig = {
      init.defaultBranch = "main";
      merge.ff = false;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.autoFetch = false; # too many "yubikey waiting for touch" prompts
    };
  };
}

{
  osConfig,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    userName = config.home.username;
    userEmail = osConfig.userOpts.githubEmail;
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

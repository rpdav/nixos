{userSettings, ...}: {
  programs.git = {
    enable = true;
    userName = userSettings.username;
    userEmail = userSettings.githubEmail;
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

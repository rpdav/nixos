{...}: {
  flake.homeModules.core = {...}: {
    programs.git = {
      enable = true;
      signing.format = "openpgp";
      settings = {
        user = {
          name = "ryan";
          email = "105075689+rpdav@users.noreply.github.com";
        };
        init.defaultBranch = "main";
      };
    };

    programs.lazygit = {
      enable = true;
      settings = {
        git.autoFetch = false; # too many "yubikey waiting for touch" prompts
      };
    };
  };
}

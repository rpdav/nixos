{self, ...}: {
  flake.homeModules."ariel@vivobook" = {...}: {
    ## This file contains all home-manager config unique to user ariel on host fw13

    imports = with self.homeModules; [
      # core config
      core

      # optional config
      firefox
      chromium
      nextcloud
      defaultApps
      kitty
      webAppConfig
      cinnamon
    ];

    home.username = "ariel";
    home.homeDirectory = "/home/ariel";

    userOpts = {
      impermanent = false;
    };

    backupOpts = {
      patterns = [
        "- **/.Trash*" #automatically made by gui deletions
        "- /persist/home/ariel/Downloads/" #big files
        "- /persist/home/ariel/Nextcloud" #already on server
        "+ /persist/home/ariel" #back up everything else
      ];
      localRepo = "ssh://borg@borg:2222/backup";
      #remoteRepo = "";
    };
  };
}

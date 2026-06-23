{self, ...}: {
  flake.homeModules."ryan@vivobook" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host fw13

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      user-ryan

      # optional config
      firefox
      chromium
      webAppConfig
      kitty
      defaultApps
      cinnamon
    ];

    userOpts = {
      impermanent = false;
    };

    backupOpts = {
      patterns = [
        "- **/.git" #can be restored from repos
        "- **/.Trash*" #automatically made by gui deletions
        "- /persist/home/ryan/Downloads/" #big files
        "- /persist/home/ryan/Nextcloud" #already on server
        "+ /persist/home/ryan" #back up everything else
      ];
      localRepo = "ssh://borg@borg:2222/backup";
      #remoteRepo = "";
    };
  };
}

{...}: {
  flake.homeModules."ariel@vivobook" = {self, ...}: {
    ## This file contains all home-manager config unique to user ariel on host fw13

    imports = [
      # core config
      self.homeModules.core

      # optional config
      #"home/common/optional/app/browser" # is A good with this config?
      #"home/common/optional/app/defaultapps.nix"
      #"home/common/optional/app/nextcloud.nix"
      #"home/common/optional/app/kitty.nix"
      #"home/common/optional/app/web-apps"
      #"home/common/optional/wm/hyprland" # this should probably be cinnamon
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

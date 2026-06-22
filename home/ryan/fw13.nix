{self, ...}: {
  flake.homeModules."ryan@fw13" = {...}: {
    ## This file contains all home-manager config unique to user ryan on host fw13

    imports = with self.homeModules; [
      # core config
      core

      # base user config
      ryan

      # optional config
      webAppConfig
      defaultApps
      accounts
      yubikeyConfig

      # apps
      firefox
      chromium
      games
      nextcloud
      kitty
      thunderbird

      # wm
      hyprland
      hypridle
      hyprlock
      waybar
      wlogout
    ];

    # Hyprland monitor config
    monitors = [
      {
        name = "DP-12";
        width = 1920;
        height = 1080;
        refreshRate = 60;
        x = 0;
        y = 0;
        scaling = 1.0;
        enabled = true;
      }
      {
        name = "DP-10";
        width = 1920;
        height = 1080;
        refreshRate = 144;
        x = 1920;
        y = 0;
        scaling = 1.0;
        enabled = true;
      }
      {
        name = "eDP-1";
        width = 2880;
        height = 1920;
        refreshRate = 120;
        x = 3840;
        y = 0;
        scaling = 2.0;
        enabled = true;
      }
    ];

    backupOpts = {
      patterns = [
        "- **/.git" # can be restored from repos
        "- **/.Trash*" # automatically made by gui deletions
        "- **/.local/share/libvirt" # vdisks made mostly for testing
        "- /persist/home/ryan/Downloads/" # big files
        "- /persist/home/ryan/Nextcloud" # already on server
        "- /persist/home/ryan/.thunderbird/*/ImapMail" # email
        "- /persist/home/ryan/.local/share/Steam" # lots of small files and big games
        "- /persist/home/ryan/.local/share/lutris" # lots of small files and big games
        "- /persist/home/ryan/.local/share/protonmail" # email
        "+ /persist/home/ryan" # back up everything else
      ];
      localRepo = "ssh://borg@borg:2222/backup";
      #remoteRepo = "";
    };

    # virt-manager settings
    #TODO Move this to virtualization module
    dconf.settings = {
      "org/virt-manager/virt-manager" = {
        xmleditor-enabled = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [
          "qemu+ssh://root@10.10.1.17/system"
          "qemu:///system"
        ];
        uris = [
          "qemu+ssh://root@10.10.1.17/system"
          "qemu:///system"
        ];
      };
    };
  };
}

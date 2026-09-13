{
  self,
  inputs,
  ...
}: {
  flake.homeModules."ryan@fw13" = {
    osConfig,
    config,
    pkgs,
    ...
  }: {
    ## This file contains all home-manager config unique to user ryan on host fw13

    imports = with self.homeModules;
      [
        # core config
        core

        # optional config
        backup
        webApps
        defaultApps
        accounts
        yubikey

        # apps
        firefox
        chromium
        games
        nextcloud
        kitty
        thunderbird

        # wm
        #hyprland
        niri
      ]
      ++ [
        self.modules.homeManager.monitors
        self.modules.homeManager.failureNotify
      ];

    # Monitor config
    monitors = {
      "Dell Inc. DELL SE2422H 5GBXZN3" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
        enable = true;
      };
      "Acer Technologies VG240Y P 0x93923D02" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.0;
        };
        position = {
          x = 1920;
          y = 0;
        };
        scale = 1.0;
        variable-refresh-rate = true;
        enable = true;
      };
      eDP-1 = {
        mode = {
          width = 2880;
          height = 1920;
          refresh = 120.0;
        };
        position = {
          x = 3840;
          y = 0;
        };
        scale = 2.0;
        variable-refresh-rate = true;
        enable = true;
      };
    };

    backupOpts = {
      patterns = [
        "R /persist/home/ryan"
        "- **/.git" # can be restored from repos
        "- **/.Trash*" # automatically made by gui deletions
        "- **/.local/share/libvirt" # vdisks made mostly for testing
        "- /persist/home/ryan/.cache/" # big files
        "- /persist/home/ryan/Downloads/" # big files
        "- /persist/home/ryan/Nextcloud" # already on server
        "- /persist/home/ryan/.config/mozilla/firefox" # lots of small files and churn
        "- /persist/home/ryan/.thunderbird/*/ImapMail" # email
        "- /persist/home/ryan/.local/share/Steam" # lots of small files and big games
        "- /persist/home/ryan/.local/share/lutris" # lots of small files and big games
        "- /persist/home/ryan/.local/share/protonmail" # email
      ];
      repo = "ssh://borg@borg:2222/backup";
    };

    services.failureNotify = {
      enable = true;
      mailFrom = "${osConfig.networking.hostName}@${inputs.nix-secrets.selfhosting.domain}";
      mailTo = inputs.nix-secrets.${osConfig.systemOpts.primaryUser}.email.personal-mail.address;
      sendmailPath = "/run/wrappers/bin/sendmail";
      units = [
        "borgmatic"
      ];
    };

    # fw13-specific programs
    programs.joplin-desktop = {
      enable = true;
      general.editor = "${pkgs.kitty} ${config.home.sessionVariables.EDITOR}";
    };

    home.persistence.${osConfig.systemOpts.persistVol} = {
      directories = [".config/joplin-desktop"];
    };
  };
}

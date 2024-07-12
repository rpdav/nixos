{ config, pkgs, impermanence, nur, secrets, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in {
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports =
    [ ./app/browser/firefox.nix
      ./app/browser/chromium.nix
    ];

  home.packages = with pkgs; [
    protonmail-bridge-gui
    thunderbird
    firefox
    tree
    onlyoffice-bin
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -la";
      ## nix commands
      nix-switch = "sudo nixos-rebuild switch --flake /home/ryan/.nixops";
      rebuild = "bash ~/scripts/rebuild.sh";
      fs-diff = "bash ~/scripts/fs-diff.sh";
      ## wireguard
      wgup = "bash ~/scripts/wgup.sh";
      wgdown = "bash ~/scripts/wgdown.sh";
    };
  };

  programs.git = {
    enable = true;
    userName = "ryan";
    userEmail = "${secrets.personal-mail.address}";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.vim = {
    enable = true;
    settings = {
      mouse = "a";
      number = true;
      relativenumber = true;
      tabstop = 2;
    };
    extraConfig =
    ''
      set autoindent
      set smartindent
    '';
  };

  programs.ssh = {
    enable = true;
    userKnownHostsFile = "/persist/home/ryan/.ssh/known_hosts";
  };

  programs.bash.historyFile = "/persist/home/ryan/.bash_history";

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };


  programs.thunderbird = {
    enable = true;
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
    profiles.ryan = {
      isDefault = true;
    };
  };

  accounts.email.accounts = {
    personal = {
      address = "${secrets.personal-mail.address}";
      userName = "${secrets.personal-mail.address}";
      realName = "${secrets.personal-mail.realName}";
      primary = true;
      imap = {
        host = "127.0.0.1";
        tls.enable = true;
        tls.useStartTls = true;
        port = 1143;
      };
      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls.enable = true;
        tls.useStartTls = true;
      };
      thunderbird = {
        enable = true;
        profiles = [ "ryan" ];
      };
    };
    admin = {
      address = "${secrets.admin-mail.address}";
      userName = "${secrets.admin-mail.address}";
      realName = "${secrets.admin-mail.realName}";
      imap = {
        host = "${secrets.admin-mail.host}";
        tls.enable = true;
        port = 993;
      };
      smtp = {
        host = "${secrets.admin-mail.host}";
        tls.enable = true;
        port = 465;
      };
      thunderbird = {
        enable = true;
        profiles = [ "ryan" ];
      };
    };
  };

  ## can't get this to talk to any calendar apps. not sure if it's even authenticating with the server.
  accounts.calendar = {
    basePath = ".calendar";
    accounts.nextcloud = {
      primary = true;
      name = "nextcloud";
      remote = {
        type = "caldav";
        url = "https://cloud.***REMOVED***/remote.php/dav/";
        userName = "ryan";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}


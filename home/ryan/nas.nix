{
  config,
  lib,
  configLib,
  outputs,
  ...
}: let
  inherit (config.systemOpts) persistVol;
in {
  ## This file contains all home-manager config unique to user ryan on host nas

  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "home/common/core"

      # optional config
      "home/common/optional/app/browser"
      "home/common/optional/app/defaultapps.nix"
      "home/common/optional/app/games"
      "home/common/optional/app/kitty.nix"
      "home/common/optional/config/persist.nix"
      #"home/common/optional/wm/gnome.nix"
    ])
    # multi-system config for current user
    ./common/core

    ./common/optional/yubikey.nix
    ./common/optional/accounts.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  #monitors = [
  #  {
  #    name = "DP-12";
  #    width = 1920;
  #    height = 1080;
  #    refreshRate = 60;
  #    x = 0;
  #    y = 0;
  #    scaling = 1.0;
  #    enabled = true;
  #  }
  #  {
  #    name = "DP-10";
  #    width = 1920;
  #    height = 1080;
  #    refreshRate = 144;
  #    x = 1920;
  #    y = 0;
  #    scaling = 1.0;
  #    enabled = true;
  #  }
  #];

  home.stateVersion = "24.11"; # don't change without reading release notes

  backupOpts = {
    patterns = [
      "- **/.git" #can be restored from repos
      "- **/.Trash*" #automatically made by gui deletions
      "- **/.local/share/libvirt" #vdisks made mostly for testing
      "- ${persistVol}/home/ryan/Downloads/" #big files
      "- ${persistVol}/home/ryan/Nextcloud" #already on server
      "- ${persistVol}/home/ryan/.thunderbird/*/ImapMail" #email
      "- ${persistVol}/home/ryan/.local/share/Steam" #lots of small files and big games
      "- ${persistVol}/home/ryan/.local/share/lutris" #lots of small files and big games
      "- ${persistVol}/home/ryan/.local/share/protonmail" #email
      "+ ${persistVol}/home/ryan" #back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

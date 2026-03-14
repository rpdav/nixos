{
  config,
  lib,
  configLib,
  pkgs,
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
      "home/common/optional/config/persist.nix"
    ])
    # multi-system config for current user
    ./common/core

    ./common/optional/yubikey.nix
    ./common/optional/accounts.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  # Minimal hyprland config for terminal access
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = let
      perma-kitty = pkgs.writeShellScript "perma-kitty" ''
        while true; do
            ${pkgs.kitty}/bin/kitty --start-as=fullscreen
            sleep 1
        done
      '';
    in ''
      exec-once = ${perma-kitty}

      # Window rules to enforce the TTY look
      # This ensures that even if you launch other terminals, they default to fullscreen
      #windowrulev2 = fullscreen, class:(kitty)

      bind = SUPER, L, exec, loginctl lock-sessions
      bind = SUPER, D, exec, loginctl terminate-user $USER

      # Minimalist TTY-like behavior:
      # Disable borders and gaps to make the terminal touch the edges of the screen
      general {
          gaps_in = 0
          gaps_out = 0
          border_size = 0
      }

      # Optional: Disable decorations for a pure "black screen with text" look
      decoration {
          rounding = 0
          blur {
              enabled = false
          }
      }
    '';
  };

  home.stateVersion = "24.11"; # don't change without reading release notes

  backupOpts = {
    patterns = [
      "- **/.git" # can be restored from repos
      "- **/.Trash*" # automatically made by gui deletions
      "- **/.local/share/libvirt" # vdisks made mostly for testing
      "- ${persistVol}/home/ryan/Downloads/" # big files
      "- ${persistVol}/home/ryan/Nextcloud" # already on server
      "- ${persistVol}/home/ryan/.thunderbird/*/ImapMail" # email
      "- ${persistVol}/home/ryan/.local/share/Steam" # lots of small files and big games
      "- ${persistVol}/home/ryan/.local/share/lutris" # lots of small files and big games
      "- ${persistVol}/home/ryan/.local/share/protonmail" # email
      "+ ${persistVol}/home/ryan" # back up everything else
    ];
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "";
  };
}

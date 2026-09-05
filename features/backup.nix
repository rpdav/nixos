{
  flake.nixosModules.backup = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.backupOpts) patterns repo paths;
    root-restore = pkgs.writeShellScriptBin "root-restore" ''
      if [ "$EUID" -ne 0 ]; then
        echo "This script requires root privileges. Elevating..."
        exec sudo "$0" "$@"
      fi
      rm -rf /tmp/borg
      mkdir /tmp/borg
      BORG_PASSCOMMAND="cat ${config.sops.secrets."borg/passphrase".path}" \
      borg --rsh="ssh -i ${config.sops.secrets."root/sshKeys/id_borg".path}" \
      mount ${config.services.borgbackup.jobs."local".repo} \
      /tmp/borg
    '';
    backup-mount = pkgs.writeShellScriptBin "backup-mount" ''
      echo "Please choose which backup to mount:"
      select opt in system user rclone quit
      do
          case $opt in
              "system")
                  root-restore
                  break
                  ;;
              "user")
                  user-restore
                  break
                  ;;
              "rclone")
                  rclone-restore
                  break
                  ;;
              "quit")
                  echo "Exiting..."
                  break
                  ;;
              *)
                  echo "Invalid option $REPLY. Please try again."
                  ;;
          esac
      done
    '';
    backup-umount = pkgs.writeShellScriptBin "backup-umount" ''
      echo "Please choose which backup to unmount:"
      select opt in system user rclone quit
      do
          case $opt in
              "system")
                  if [ "$EUID" -ne 0 ]; then
                    echo "This script requires root privileges. Elevating..."
                    exec sudo "$0" "$@"
                  fi
                  borg umount /tmp/borg
                  rm -rf /tmp/borg
                  break
                  ;;
              "user")
                  borg umount /tmp/borg
                  rm -rf /tmp/borg
                  break
                  ;;
              "rclone")
                  if [ "$EUID" -ne 0 ]; then
                    echo "This script requires root privileges. Elevating..."
                    exec sudo "$0" "$@"
                  fi
                  fusermount -u /tmp/rclone/B2
                  fusermount -u /tmp/rclone/crypt
                  rm -rf /tmp/rclone
                  break
                  ;;
              "quit")
                  echo "Exiting..."
                  break
                  ;;
              *)
                  echo "Invalid option $REPLY. Please try again."
                  ;;
          esac
      done
    '';
  in {
    environment.systemPackages = [root-restore backup-mount backup-umount];

    # Pull passphrase and key for ssh access
    sops.secrets = {
      "borg/passphrase" = {
        mode = "0444"; # users will use system passphrase in order to keep vps host from accessing user backups
      };
      "root/sshKeys/id_borg" = {
      };
    };

    # ssh config for borg
    programs.ssh = {
      extraConfig = ''
        Host borg
          Port 2222
          User borg
          IdentityFile ${config.sops.secrets."root/sshKeys/id_borg".path}
          IdentitiesOnly yes
          IdentityAgent none
      '';
      knownHosts."[borg]:2222".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4g3UjhXc1bngjSuUhDJm1aioym5kjbggI/UoAbE7kv root@7d4566122ec5";
    };

    services.borgbackup.jobs."local" = {
      inherit paths patterns;
      user = "root";
      repo = "${repo}/${config.networking.hostName}-root";
      doInit = true;
      startAt = ["daily"];
      #    preHook = placeholder for snapshotting/mounting command
      #    postHook = placeholder for snapshot deletion/unmount
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      };
      compression = "auto,lzma";
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 12;
        yearly = 1;
      };
    };
    systemd.services."borgbackup-job-local" = {
      serviceConfig = {
        ExecStartPre = [
          # Wait until ping succeeds before trying to back up
          "${pkgs.coreutils}/bin/echo \"Checking network connectivity...\""
          "/bin/sh -c 'until ${pkgs.iputils}/bin/ping -c1 -W1 1.1.1.1; do sleep 5; done'"
        ];
        # Kill service if no pong after 5 min
        TimeoutStartSec = "5m";
      };
    };
  };
  flake.homeModules.backup = {
    pkgs,
    lib,
    config,
    osConfig,
    ...
  }: let
    inherit (config.backupOpts) patterns repo;
    inherit (config.home) username;
    user-restore = pkgs.writeShellScriptBin "user-restore" ''
      rm -rf /tmp/borg
      mkdir /tmp/borg
      BORG_PASSCOMMAND="cat ${osConfig.sops.secrets."borg/passphrase".path}" \
      borg --rsh="ssh -i ${config.sops.secrets."sshKeys/id_borg".path}" \
      mount ssh://borg@borg:2222/backup/${osConfig.networking.hostName}-${username} \
      /tmp/borg
      echo "repository ${osConfig.networking.hostName}-${username} mounted at /tmp/borg"
    '';
  in {
    sops.secrets = {
      "sshKeys/id_borg" = {};
    };

    home.packages = [user-restore];

    # ssh config for borg
    programs.ssh = {
      extraConfig = ''
        Host borg
          Port 2222
          User borg
          IdentityFile ${config.sops.secrets."sshKeys/id_borg".path}
          IdentitiesOnly yes
          IdentityAgent none
      '';
    };

    systemd.user.services.borgmatic = {
      Unit.ConditionACPower = lib.mkForce "";
      Service = {
        ExecStartPre = lib.mkForce (pkgs.writeShellScript "borgmatic-pre" ''
          # Wait until ping succeeds before backing up
          echo "Checking network connectivity..."
          /bin/sh -c 'until ${pkgs.iputils}/bin/ping -c1 -W1 1.1.1.1; do sleep 5; done'
          # Ensure repo is initialized
          ${pkgs.borgmatic}/bin/borgmatic repo-create --encryption repokey-blake2 --make-parent-dirs
        '');
        # Kill service if no pong after 5 min
        TimeoutStartSec = "5m";
      };
    };

    services.borgmatic = {
      enable = true;
      frequency = "daily";
    };
    programs.borgmatic = {
      enable = true;
      backups."${username}-local" = {
        location = {
          inherit patterns;
          repositories = [
            {
              "path" = "${repo}/${osConfig.networking.hostName}-${username}";
              "label" = "local";
            }
          ];
          excludeHomeManagerSymlinks = true;
        };
        storage.encryptionPasscommand = "cat ${osConfig.sops.secrets."borg/passphrase".path}";
        retention = {
          keepDaily = 7;
          keepWeekly = 4;
          keepMonthly = 12;
          keepYearly = 1;
        };
      };
    };
  };
}

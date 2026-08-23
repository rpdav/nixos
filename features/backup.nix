{inputs, ...}: {
  flake.nixosModules.backup = {config, ...}:
  #TODO: get backup monitor working again
  #let
  #  ## Set up notifications in case of failure
  #  borgbackupMonitor = {
  #    config,
  #    pkgs,
  #    lib,
  #    ...
  #  }:
  #    with lib; {
  #      key = "borgbackupMonitor";
  #      _file = "borgbackupMonitor";
  #      config.systemd.services =
  #        {
  #          "notify-problems@" = {
  #            enable = true;
  #            serviceConfig.User = "danbst";
  #            environment.SERVICE = "%i";
  #            script = ''
  #              export $(cat /proc/$(${pkgs.procps}/bin/pgrep "gnome-session" -u "$USER")/environ |grep -z '^DBUS_SESSION_BUS_ADDRESS=')
  #              ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
  #            '';
  #          };
  #        }
  #        // flip mapAttrs' config.services.borgbackup.jobs (
  #          name: value:
  #            nameValuePair "borgbackup-job-${name}" {
  #              unitConfig.OnFailure = "notify-problems@%i.service";
  #              ## Wait for network access
  #              preStart = lib.mkBefore ''
  #                # waiting for internet after resume-from-suspend
  #                until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do :; done
  #              '';
  #            }
  #        );
  #
  #      # optional, but this actually forces backup after boot in case laptop was powered off during scheduled event
  #      # for example, if you scheduled backups daily, your laptop should be powered on at 00:00
  #      config.systemd.timers = flip mapAttrs' config.services.borgbackup.jobs (
  #        name: value:
  #          nameValuePair "borgbackup-job-${name}" {
  #            timerConfig.Persistent = lib.mkForce true;
  #          }
  #      );
  #    };
  #in
  let
    inherit (config.backupOpts) patterns repo paths;
    restartUnits = ["borgbackup-job-local"]; # this causes activation errors - name might be wrong?
  in {
    #  imports = [
    #    borgbackupMonitor
    #  ];

    # This config assumes this machine's root user public key is copied to the borg server as /sshkeys/clients/$hostname. The server will create a backup directory under /backup/$hostname-root

    # Pull passphrase and key for ssh access
    sops.secrets = {
      "borg/passphrase" = {
        #inherit restartUnits;
        mode = "0444"; # users will use system passphrase in order to keep vps host from accessing user backups
      };
      "root/sshKeys/id_borg" = {
        #inherit restartUnits;
      };
    };

    # ssh config for borg
    programs.ssh = {
      extraConfig = ''
        Host borg
          Hostname 10.10.1.17
          Port 2222
          User borg
          IdentityFile ${config.sops.secrets."root/sshKeys/id_borg".path}
          IdentitiesOnly yes
          IdentityAgent none
      '';
      knownHosts."[borg]:2222" = {
        extraHostNames = ["[10.10.1.17]:2222"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4g3UjhXc1bngjSuUhDJm1aioym5kjbggI/UoAbE7kv root@7d4566122ec5";
      };
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
  in {
    sops.secrets = {
      "sshKeys/id_borg" = {};
    };

    # ssh config for borg
    programs.ssh = {
      extraConfig = ''
        Host borg
          Hostname 10.10.1.17
          Port 2222
          User borg
          IdentityFile ${config.sops.secrets."sshKeys/id_borg".path}
          IdentitiesOnly yes
          IdentityAgent none
      '';
    };

    systemd.user.services.borgmatic = {
      #Ensure repo is initialized
      Service.ExecStartPre = lib.mkForce ["${pkgs.borgmatic}/bin/borgmatic repo-create --encryption repokey-blake2 --make-parent-dirs"];
      Unit.ConditionACPower = lib.mkForce "";
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
        storage.encryptionPasscommand = "${pkgs.coreutils}/bin/cat ${osConfig.sops.secrets."borg/passphrase".path}";
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

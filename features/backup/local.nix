{inputs, ...}: {
  flake.nixosModules.backupLocal = {config, ...}:
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
    inherit (config.backupOpts) patterns localRepo paths;
    sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
    restartUnits = ["borgbackup-job-local"];
  in {
    #  imports = [
    #    borgbackupMonitor
    #  ];

    # This config assumes this machine's root user public key is copied to the borg server as /sshkeys/clients/$hostname. The server will create a backup directory under /backup/$hostname

    ## Local backup definition

    # Pull passphrase and key for ssh access (not needed for NAS)
    sops.secrets = {
      "borg/passphrase" = {
        inherit sopsFile restartUnits;
      };
      "root/sshKeys/id_borg" = {
        inherit sopsFile restartUnits;
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
    };

    services.borgbackup.jobs."local" = {
      inherit paths patterns;
      user = "root";
      repo = "${localRepo}/${config.networking.hostName}/root";
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
    inherit (config.backupOpts) patterns localRepo;
    inherit (config.home) username;
  in {
    sops.secrets = {
      "sshKeys/id_borg" = {};
      "borg/passphrase" = {
        sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      };
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

    #Ensure repo is initialized
    systemd.user.services.borgmatic.Service.ExecStartPre = lib.mkForce [
      "${pkgs.borgmatic}/bin/borgmatic repo-create --encryption repokey-blake2 --make-parent-dirs"
    ];

    services.borgmatic.enable = true;
    programs.borgmatic = {
      enable = true;
      backups."${username}" = {
        location = {
          inherit patterns;
          repositories = [
            {
              "path" = "${localRepo}/${osConfig.networking.hostName}/${username}";
              "label" = "local";
            }
          ];
          excludeHomeManagerSymlinks = true;
        };
        storage.encryptionPasscommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."borg/passphrase".path}";
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

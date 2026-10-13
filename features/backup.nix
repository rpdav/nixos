{self, ...}: {
  flake.nixosModules.backup = {
    config,
    pkgs,
    lib,
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
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    environment.systemPackages = [
      # root-restore # comment out while transitioning to borgmatic
      selfpkgs.backup-mount
      selfpkgs.backup-umount
    ];

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

    #systemd.services."borgbackup-job-local" = {
    #  serviceConfig = {
    #    ExecStartPre = [
    #      # Wait until ping succeeds before trying to back up
    #      "${pkgs.coreutils}/bin/echo \"Checking network connectivity...\""
    #      "/bin/sh -c 'until ${pkgs.iputils}/bin/ping -c1 -W1 1.1.1.1; do sleep 5; done'"
    #    ];
    #    # Kill service if no pong after 5 min
    #    TimeoutStartSec = "5m";
    #  };
    #};

    services.borgmatic = {
      enable = true;
      settings = {
        source_directories = paths;
        inherit patterns;
        repositories = [
          {
            "path" = "${repo}/${config.networking.hostName}-root";
            "label" = "local";
          }
        ];
        encryption_passcommand = "cat ${config.sops.secrets."borg/passphrase".path}";
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
        keep_yearly = 1;
      };
    };
    systemd.services.borgmatic = {
      unitConfig.ConditionACPower = "";
      serviceConfig.ExecStartPre = [
        ""
        (pkgs.writeShellScript "borgmatic-pre" ''
          # Wait until ping succeeds before backing up
          echo "Checking network connectivity..."
          /bin/sh -c 'until ${pkgs.iputils}/bin/ping -c1 -W1 1.1.1.1; do sleep 5; done'
          # Ensure repo is initialized
          #${pkgs.borgmatic}/bin/borgmatic \
          #repo-create --encryption repokey-blake2 --make-parent-dirs
        '')
      ];
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
    inherit (config.home) username homeDirectory;
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
          ${config.programs.borgmatic.package}/bin/borgmatic \
          -c ${homeDirectory}/.config/borgmatic.d/${username}-local.yaml \
          repo-create --encryption repokey-blake2 --make-parent-dirs
        '');
        # Manually specify config location to prevent conflicts with system module
        ExecStart = lib.mkForce ''
          ${pkgs.systemd}/bin/systemd-inhibit \
            --who="borgmatic" \
            --what="sleep:shutdown" \
            --why="Prevent interrupting scheduled backup" \
            ${config.programs.borgmatic.package}/bin/borgmatic \
              -c ${homeDirectory}/.config/borgmatic.d/${username}-local.yaml \
              --stats \
              --verbosity -1 \
              --list \
              --syslog-verbosity 1
        ''; # Kill service if no pong after 5 min
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
        location.excludeHomeManagerSymlinks = true;
        settings = {
          inherit patterns;
          repositories = [
            {
              "path" = "${repo}/${osConfig.networking.hostName}-${username}";
              "label" = "local";
            }
          ];
          encryption_passcommand = "cat ${osConfig.sops.secrets."borg/passphrase".path}";
          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 12;
          keep_yearly = 1;
        };
      };
    };
  };
}

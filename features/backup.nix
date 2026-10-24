{self, ...}: {
  flake.nixosModules.backup = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (config.backupOpts) patterns repo paths;
    root-restore = pkgs.writeShellScriptBin "root-restore" ''
      rm -rf /tmp/borg
      mkdir /tmp/borg
      ${pkgs.borgmatic}/bin/borgmatic mount --archive latest \
      --mount-point /tmp/borg
    '';
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    environment.systemPackages = [
      root-restore
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
          Hostname ${self.deploy.nodes.nas.hostname}
          IdentityFile ${config.sops.secrets."root/sshKeys/id_borg".path}
          IdentitiesOnly yes
          IdentityAgent none
      '';
      knownHosts = {
        "[borg]:2222".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4g3UjhXc1bngjSuUhDJm1aioym5kjbggI/UoAbE7kv root@7d4566122ec5";
        # Have to declare both the hostname and the IP. Not sure why
        "[${self.deploy.nodes.nas.hostname}]:2222".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4g3UjhXc1bngjSuUhDJm1aioym5kjbggI/UoAbE7kv root@7d4566122ec5";
      };
    };

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
      serviceConfig = {
        ExecStartPre = [
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
    inherit (config.home) username homeDirectory;
    user-restore = pkgs.writeShellScriptBin "user-restore" ''
      rm -rf /tmp/borg
      mkdir /tmp/borg
      ${pkgs.borgmatic}/bin/borgmatic mount --archive latest \
      -c ${config.xdg.configHome}/borgmatic.d/${username}-local --mount-point /tmp/borg
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
          # system ssh config contains everything except key path
          IdentityFile ${config.sops.secrets."sshKeys/id_borg".path}
      '';
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

    services.borgmatic = {
      enable = true;
      frequency = "daily";
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
  };
}

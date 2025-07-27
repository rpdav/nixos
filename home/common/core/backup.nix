{
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
    "borg/passphrase" = {};
    "${username}/sshKeys/id_borg" = {};
  };

  # ssh config for borg
  programs.ssh = {
    extraConfig = ''
      Host borg
        Hostname 10.10.1.17
        Port 2222
        User borg
        IdentityFile ${config.sops.secrets."${username}/sshKeys/id_borg".path}
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
}

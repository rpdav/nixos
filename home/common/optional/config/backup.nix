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

  #testing only - allow backups on battery
  systemd.user.services.borgmatic.Unit.ConditionACPower = lib.mkForce false;

  # prioritize borg key for borg host
  programs.ssh = {
    extraConfig = ''
      Host borg
        Hostname 10.10.1.17
        Port 2222
        User borg
        IdentityFile ${config.sops.secrets."${username}/sshKeys/id_borg".path}
        IdentitiesOnly yes
    '';
  };

  #Ensure repo is created and initialized
  systemd.user.services.borgmatic.Service.ExecStartPre = lib.mkForce [
    #"${pkgs.coreutils}/bin/mkdir -p ${config.backupOpts.localRepo}/${osConfig.networking.hostName}/${config.home.username}"
    #"${pkgs.borgmatic}/bin/borgmatic repo-create --encryption repokey-blake2"
  ];
  # local backup config
  services.borgmatic.enable = true;
  home.packages = [pkgs.borgmatic];
  #  programs.borgmatic = {
  #    enable = true;
  #    backups."${username}" = {
  #      location = {
  #        # inherit sourceDirectories;
  #        inherit patterns;
  #        repositories = [
  #          #  {
  #          #    path = config.backupOpts.remoteRepo;
  #          #    label = "remote";
  #          #  }
  #          {
  #            "path" = "${localRepo}/${osConfig.networking.hostName}/${username}";
  #            "label" = "local";
  #            #"encryption" = "repokey-blake2";
  #          }
  #        ];
  #        extraConfig = {
  #          ssh_command = "ssh -i ${config.sops.secrets."${username}/sshKeys/id_borg".path} -o IdentitiesOnly=yes";
  #        };
  #        excludeHomeManagerSymlinks = true;
  #      };
  #      storage.encryptionPasscommand = "cat ${config.sops.secrets."borg/passphrase".path}";
  #      retention = {
  #        keepDaily = 7;
  #        keepWeekly = 4;
  #        keepMonthly = 12;
  #        keepYearly = 1;
  #      };
  #    };
  #  };
}

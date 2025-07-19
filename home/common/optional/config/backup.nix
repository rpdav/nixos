{
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

  # local backup config
  services.borgmatic.enable = true;
  programs.borgmatic = {
    enable = true;
    backups."${username}-local" = {
      location = {
        # inherit sourceDirectories;
        inherit patterns;
        repositories = [
          #  {
          #    path = config.backupOpts.remoteRepo;
          #    label = "remote";
          #  }
          {
            "path" = "${localRepo}/${osConfig.networking.hostName}/${username}";
            "label" = "local";
            #"encryption" = "repokey-blake2";
          }
        ];
        extraConfig = {
          ssh_command = "ssh -i ${config.sops.secrets."${username}/sshKeys/id_borg".path}";
        };
        excludeHomeManagerSymlinks = true;
      };
      storage.encryptionPasscommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      retention = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 12;
        keepYearly = 1;
      };
    };
  };
}

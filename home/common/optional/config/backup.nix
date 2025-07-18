{
  config,
  osConfig,
  ...
}: let
  inherit (config.backupOpts) sourcePaths patterns localRepo;
  inherit (config.home) username;
in {
  sops.secrets = {
    "borg/passphrase" = {};
    "${username}/sshKeys/id_borg" = {};
  };

  # local backup config
  programs.borgmatic = {
    enable = true;
    "${username}-local" = {
      location = {
        inherit sourcePaths;
        inherit patterns;
        repositories = [
          #  {
          #    path = config.backupOpts.remoteRepo;
          #    label = "remote";
          #  }
          {
            path = "${localRepo}/${osConfig.networking.hostName}/${username}";
            label = "local";
            encryption = "repokey-blake2";
          }
        ];
        extraConfig = {
          ssh_command = "ssh -i ${config.sops.secrets."${username}/sshKeys/id_borg".path}";
        };
        excludeHomeManagerSymlinks = true;
      };
      storage.encryptionPassCommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      retention = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 12;
        keepYearly = 1;
      };
    };
  };
}

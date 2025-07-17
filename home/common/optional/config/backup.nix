{
  config,
  osConfig,
  ...
}: let
  inherit (config.backupOpts) sourcePaths patterns localRepo;
  inherit (config.home) username;
in {
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
          }
        ];
        excludeHomeManagerSymlinks = true;
      };
      storage.encryptionPassCommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      retention = {
      };
    };
  };
}

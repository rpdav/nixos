{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.backupOpts) patterns remoteRepo paths;
  inherit (config.networking) hostName;
  sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
  restartUnits = ["borgbackup-job-remote"];
in {
  sops.secrets = {
    # Pull B2 config file from secrets
    "rclone/config" = {
      inherit sopsFile restartUnits;
    };
    # Pull borg passphrase and repo config
    "borg/passphrase" = {
      inherit sopsFile restartUnits;
    };
  };

  services.borgbackup.jobs."remote" = {
    inherit paths patterns;
    user = "root";
    repo = "${remoteRepo}";
    doInit = true;
    startAt = ["weekly"];
    preHook = ''
      # create mount directory if not exists
      mkdir -p ${remoteRepo}
    '';
    postHook = "${pkgs.rclone}/bin/rclone sync ${remoteRepo} B2-crypt:${hostName}/root --config ${
      config.sops.secrets."rclone/config".path
    }";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets."borg/passphrase".path}"; # This is also in password manager under entry "Borg backup"
    };
    compression = "auto,lzma";
    prune.keep = {
      weekly = 4;
      monthly = 12;
      yearly = 1;
    };
  };
}

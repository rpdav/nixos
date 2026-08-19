{inputs, ...}: {
  flake.nixosModules.backupRemote = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.backupOpts) patterns remoteRepo paths;
    inherit (config.networking) hostName;
    restartUnits = ["borgbackup-job-remote"];
  in {
    sops.secrets = {
      # Pull B2 credentials from secrets
      "rclone/b2/account" = {
        inherit restartUnits;
      };
      "rclone/b2/key" = {
        inherit restartUnits;
      };
      # Pull borg passphrase and repo config
      "borg/passphrase" = {
        inherit restartUnits;
      };
    };
    # Create rclone config from secrets
    sops.templates."rclone-b2".content = ''
      [B2]
      type = b2
      account = ${config.sops.placeholder."rclone/b2/account"}
      key = ${config.sops.placeholder."rclone/b2/key"}
      hard_delete = true
    '';

    # This needs retooled - it's doing a new backup locally and then pushing it to the cloud.
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
      postHook = "${pkgs.rclone}/bin/rclone sync ${remoteRepo} B2:rclone428/backups/${hostName}/root --config ${config.sops.templates."rclone-b2".path}";
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
  };
}

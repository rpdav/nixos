{inputs, ...}: {
  flake.nixosModules.backupRemote = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.backupOpts) patterns remoteRepo paths;
    inherit (config.networking) hostName;
  in {
    sops.secrets = {
      # Pull B2 credentials from secrets
      "rclone/b2/account" = {
      };
      "rclone/b2/key" = {
      };
      "rclone/crypt/password" = {};
    };
    # Create rclone config from secrets
    sops.templates."rclone.conf".content = ''
      [B2]
      type = b2
      account = ${config.sops.placeholder."rclone/b2/account"}
      key = ${config.sops.placeholder."rclone/b2/key"}
      hard_delete = true

      [B2-crypt]
      type = crypt
      remote = B2:rpdav-rclone/crypt
      password = ${config.sops.placeholder."rclone/crypt/password"}
    '';

    systemd.services."rclone-borg" = {
      script = ''
        ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync /mnt/storage/backups/borg-test B2:rpdav-rclone/borg-test
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
    systemd.timers."rclone-borg" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "rclone-borg.service";
      };
    };

    systemd.services."rclone-media" = {
      script = ''
        ${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync /mnt/storage/backups/media-test B2-crypt:media-test
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
    systemd.timers."rclone-media" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "rclone-media.service";
      };
    };
    # This needs retooled - it's doing a new backup locally and then pushing it to the cloud.
    #services.borgbackup.jobs."remote" = {
    #  inherit paths patterns;
    #  user = "root";
    #  repo = "${remoteRepo}";
    #  doInit = true;
    #  startAt = ["weekly"];
    #  preHook = ''
    #    # create mount directory if not exists
    #    mkdir -p ${remoteRepo}
    #  '';
    #  postHook = "${pkgs.rclone}/bin/rclone sync ${remoteRepo} B2:rclone428/backups/${hostName}/root --config ${config.sops.templates."rclone-b2".path}";
    #  encryption = {
    #    mode = "repokey-blake2";
    #    passCommand = "cat ${config.sops.secrets."borg/passphrase".path}"; # This is also in password manager under entry "Borg backup"
    #  };
    #  compression = "auto,lzma";
    #  prune.keep = {
    #    weekly = 4;
    #    monthly = 12;
    #    yearly = 1;
    #  };
    #};
  };
}

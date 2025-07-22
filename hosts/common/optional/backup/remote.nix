{
  config,
  lib,
  pkgs,
  ...
}: {
  ### This is not up to date with current config - probably needs rebuilt

  # Pull B2 config file from secrets
  sops.secrets = {
    "rclone/config" = {};
  };

  environment.etc.rclone-exclude.text = lib.strings.concatLines config.backupOpts.excludeList;

  environment.etc.rclone-exclude-test.text = ''
    **.git
    */home
    */lib/
    */vars/**
  '';
  # Rclone sync using rclone

  ## Below config is the first attempt at borg/rclone-B2
  # Pull borg passphrase and repo config
  #  sops.secrets = {
  #    "borg/passphrase" = {};
  #    "rclone/B2-config" = {};
  #  };
  #
  #  services.borgbackup.jobs."remote" = {
  #    paths = config.backupOpts.sourcePaths;
  #    exclude = config.backupOpts.excludeList;
  #    user = "root";
  #    repo = config.backupOpts.remoteRepo + ("/" + config.networking.hostName);
  #    doInit = true;
  #    startAt = ["weekly"];
  ##    preHook = ''
  ##      # create mount directory if not exists
  ##      mkdir -p ${config.backupOpts.remoteRepo}
  ##      # mount remote repo
  ##      ${pkgs.rclone}/bin/rclone mount B2:nixos-borg ${config.backupOpts.remoteRepo} --config ${config.sops.secrets."rclone/B2-config".path}
  ##      # pause to allow time for mount
  ##      sleep 10
  ##      # create host directory if not exists
  ##      # only needed for first backup; B2 doesn't persist empty
  ##      # directories, so this must be created just before first backup
  ##      mkdir -p ${config.backupOpts.remoteRepo}/${config.networking.hostName}
  ##    '';
  ##    postHook = "umount ${config.backupOpts.remoteRepo}";
  #    encryption = {
  #      mode = "repokey-blake2";
  #      passCommand = "cat ${config.sops.secrets."borg/passphrase".path}"; #This is also in password manager under entry "Borg backup"
  #    };
  #    compression = "auto,lzma";
  #    prune.keep = {
  #      weekly = 4;
  #      monthly = 12;
  #      yearly = 1;
  #    };
  #  };
}

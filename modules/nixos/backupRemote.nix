{...}: {
  flake.modules.nixos.backupRemote = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkOption types;
    cfg = config.services.rcloneSync;
    # Filtered list of backup submodules
    enabledBackups = lib.filterAttrs (name: val: val.enable) cfg.backups;
  in {
    options.services.rcloneSync = {
      configFilePath = mkOption {
        type = with types; either str path;
        description = "Path to rclone.conf";
      };
      backups = mkOption {
        default = {};
        type = types.attrsOf (
          types.submodule ({name, ...}: {
            options = {
              enable = lib.mkEnableOption "Enable this backup";
              remote = mkOption {
                type = types.str;
                default = "";
                description = "Rclone remote and bucket to point to";
                example = "B2:myBucket";
              };
              sourceDir = mkOption {
                type = with types; nullOr path;
                default = null;
                description = "Path to backup";
                example = "/mnt/myData";
              };
              targetDir = mkOption {
                type = types.str;
                default = name;
                description = "Directory on the remote to sync to";
                example = "myData";
              };
              frequency = mkOption {
                type = types.str;
                default = "weekly";
                description = "Backup frequency. See systemd.time(7) section 'Calendar Events' for accepted formats";
                example = "daily";
              };
              preExec = mkOption {
                type = types.lines;
                default = "";
                description = "Shell commands run right before the rclone script. Useful for mounting filesystems.";
                example = "mount /dev/sdb1 /mnt/storage";
              };
              postExec = mkOption {
                type = types.lines;
                default = "";
                description = "Shell commands run right after the rclone script finishes or fails. Useful for unmounting.";
                example = "umount /mnt/storage";
              };
            };
          })
        );
      };
    };
    config = lib.mkIf (enabledBackups != {}) {
      # create service named `rclone-${name}.service`
      systemd.services = lib.mapAttrs' (name: val:
        lib.nameValuePair "rclone-${name}" {
          description = "Rclone sync service for ${name}";
          script = ''
            ${pkgs.rclone}/bin/rclone --config ${cfg.configFilePath} \
            sync ${toString val.sourceDir} ${val.remote}/${val.targetDir}
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStartPre = lib.mkIf (val.preExec != "") (pkgs.writeShellScript "rclone-${name}-pre" val.preExec);
            ExecStartPost = lib.mkIf (val.postExec != "") (pkgs.writeShellScript "rclone-${name}-post" val.postExec);
          };
        })
      enabledBackups;
      systemd.timers =
        lib.mapAttrs (name: val: {
          description = "Timer for rclone sync service ${name}";
          wantedBy = ["timers.target"];

          timerConfig = {
            OnCalendar = val.frequency;
            Persistent = true; # Runs missed jobs if the system was powered off
            Unit = "rclone-${name}.service";
          };
        })
        enabledBackups;
    };
  };
}

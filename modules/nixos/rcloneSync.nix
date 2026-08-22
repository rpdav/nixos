{...}: {
  flake.modules.nixos.rcloneSync = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkOption types mkIf mapAttrs' nameValuePair;
    cfg = config.services.rcloneSync;
    # Filtered list of backup submodules
    enabledBackups = lib.filterAttrs (name: val: val.enable) cfg.backups;
  in {
    options.services.rcloneSync = {
      configFilePath = mkOption {
        type = with types; either str path;
        description = "Path to rclone.conf";
      };
      logDir = mkOption {
        type = types.nullOr types.str;
        default = "/var/log/rclone-sync";
        description = "Directory where rclone log files will be saved. Set to null to use systemd journal only.";
        example = "/var/log/rclone";
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
              logDir = mkOption {
                type = types.nullOr types.str;
                default = "/var/log/rclone-sync";
                description = "Directory where rclone log files will be saved. Set to null to use systemd journal only.";
                example = "/var/log/rclone";
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
              extraArgs = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Extra command line arguments to pass directly to rclone.";
                example = ["--log-level" "INFO" "--fast-list"];
              };
            };
          })
        );
      };
    };
    config = mkIf (enabledBackups != {}) {
      systemd.services = mapAttrs' (name: val: let
        # Calculate log flags if a logging directory is provided
        logFlags =
          if cfg.logDir != null
          then ["--log-file" "${cfg.logDir}/${name}.log" "--log-level" "NOTICE"]
          else [];

        # Combine default log flags with user-defined extra arguments
        allArgs = logFlags ++ val.extraArgs;
      in
        nameValuePair "rclone-${name}" {
          description = "Rclone sync service for ${name}";
          script = ''
            ${pkgs.rclone}/bin/rclone --config ${cfg.configFilePath} \
            sync ${toString val.sourceDir} ${val.remote}/${val.targetDir} \
            ${lib.escapeShellArgs allArgs}
          '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            # Automatically create the logging directory securely if defined
            LogsDirectory = mkIf (cfg.logDir != null) (baseNameOf cfg.logDir);
            # Add pre and post commands if defined
            ExecStartPre = mkIf (val.preExec != "") (pkgs.writeShellScript "rclone-${name}-pre" val.preExec);
            ExecStartPost = mkIf (val.postExec != "") (pkgs.writeShellScript "rclone-${name}-post" val.postExec);
          };
        })
      enabledBackups;
      systemd.timers = mapAttrs' (name: val:
        nameValuePair "rclone-${name}" {
          description = "Timer for rclone sync service ${name}";
          wantedBy = ["timers.target"];

          timerConfig = {
            OnCalendar = val.frequency;
            Persistent = true; # Runs missed jobs if the system was powered off
            Unit = "rclone-${name}.service";
          };
        })
      enabledBackups;

      services.logrotate = mkIf (cfg.logDir != null) {
        enable = true;
        settings = {
          rcloneSync = {
            files = "${cfg.logDir}/*.log";
            frequency = "weekly";
            rotate = 4; # Keep 4 weeks of backlogs
            missingok = true; # Do not panic or throw errors if a specific backup log is missing
            notifempty = true; # Do not rotate an empty log file
            compress = true; # Gzip historical logs to save disk space
          };
        };
      };
    };
  };
}

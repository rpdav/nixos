{self, ...}: {
  flake.modules.generic.failureNotify = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.failureNotify;
    notifyScript = self.packages.${pkgs.stdenv.hostPlatform.system}.systemd-failure-notify;
    isHM = builtins.hasAttr "home" config;
    commonEnv = [
      "NOTIFY_MAILTO=${cfg.mailTo}"
      "NOTIFY_MAILFROM=${cfg.mailFrom}"
      "NOTIFY_SUBJECT_PREFIX=${cfg.subjectPrefix}"
      "NOTIFY_SENDMAIL=${cfg.sendmailPath}"
    ];
  in {
    options.services.failureNotify = {
      enable = lib.mkEnableOption "email notifications for failed systemd services";

      mailTo = lib.mkOption {
        type = lib.types.str;
        example = "me@example.com";
        description = "Address failure notifications are sent to.";
      };

      mailFrom = lib.mkOption {
        type = lib.types.str;
        default = cfg.mailTo;
        defaultText = lib.literalExpression "config.services.failureNotify.mailTo";
        description = "Address notifications appear to come from.";
      };

      subjectPrefix = lib.mkOption {
        type = lib.types.str;
        default = "[systemd]";
        description = "Short tag prepended to the notification subject line.";
      };

      sendmailPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/wrappers/bin/sendmail";
        example = "/run/current-system/sw/bin/sendmail";
        description = ''
          Name or absolute path of the sendmail-compatible binary to pipe the
          message into. Defaults to whatever `sendmail` resolves to on
          `PATH` (your msmtp install already provides this).
        '';
      };

      units = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["nginx.service" "postgresql.service"];
        description = ''
          System-level systemd units to monitor. Each listed unit gets an
          `OnFailure=` dependency on the notification service added to it,
          so the email fires immediately the moment the unit enters the
          "failed" state — nothing is batched or digested.

          Units not listed here are left completely untouched.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      systemd =
        # Split config so a single module can be used for both nixos and HM
        if isHM
        then {
          # service configuration for HM
          user.services =
            # 1. attach OnFailure= to every unit the user opted in
            (lib.genAttrs cfg.units (_unit: {
              Unit.OnFailure = ["failure-notify@%n.service"];
            }))
            # 2. the template unit that actually sends the mail
            // {
              "failure-notify@" = {
                Unit = {
                  Description = "Send failure notification email for %i";
                  OnFailure = lib.mkForce [];
                };
                Service = {
                  Type = "oneshot";
                  # %I = unescaped instance name (see note in the NixOS module).
                  ExecStart = "${notifyScript}/bin/systemd-failure-notify %I";
                  Environment = ["NOTIFY_MODE=user"] ++ commonEnv;
                };
              };
            };
        }
        else {
          # service configuration for nixos
          services =
            # 1. attach OnFailure= to every unit the user opted in
            (lib.genAttrs cfg.units (_unit: {
              onFailure = ["failure-notify@%n.service"];
            }))
            # 2. the template unit that actually sends the mail
            // {
              "failure-notify@" = {
                description = "Send failure notification email for %i";
                # This unit must never trigger itself, even by accident.
                onFailure = lib.mkForce [];
                serviceConfig = {
                  Type = "oneshot";
                  # %I = unescaped instance name, i.e. the real unit name (%i
                  # would be shell/path-escaped and break systemctl/journalctl
                  # lookups for units with '-', '@', etc. in their name).
                  ExecStart = "${notifyScript}/bin/systemd-failure-notify %I";
                  Environment = ["NOTIFY_MODE=system"] ++ commonEnv;
                };
              };
            };
        };
    };
  };
}

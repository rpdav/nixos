{self, ...}: {
  flake.modules.homeManager.failureNotify = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.failureNotify;
    notifyScript = self.packages.${pkgs.stdenv.hostPlatform.system}.systemd-failure-notify;
  in {
    options.services.failureNotify = {
      enable = lib.mkEnableOption "email notifications for failed systemd --user services";

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
        default = "sendmail";
        example = "/run/current-system/sw/bin/sendmail";
        description = ''
          Name or absolute path of the sendmail-compatible binary to pipe the
          message into. Must be reachable from your user session's PATH
          (your msmtp install already provides this, as long as it isn't
          installed in a system-only profile the user session can't see).
        '';
      };

      units = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["syncthing.service" "borgbackup-job-home.service"];
        description = ''
          Home-manager (systemd --user) units to monitor. Each listed unit
          gets an `OnFailure=` dependency added to it, so the email fires
          immediately when the unit enters the "failed" state.

          Units not listed here are left completely untouched.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.user.services =
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
              Environment = [
                "NOTIFY_MODE=user"
                "NOTIFY_MAILTO=${cfg.mailTo}"
                "NOTIFY_MAILFROM=${cfg.mailFrom}"
                "NOTIFY_SUBJECT_PREFIX=${cfg.subjectPrefix}"
                "NOTIFY_SENDMAIL=${cfg.sendmailPath}"
              ];
            };
          };
        };
    };
  };
}

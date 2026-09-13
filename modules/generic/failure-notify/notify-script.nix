{
  perSystem = {pkgs, ...}:
  # Builds the script that actually composes and sends the failure email.
  # Shared by both the NixOS (system) and home-manager (user) modules so the
  # email format and behavior stay identical regardless of which one fires.
  #
  # Expects to be called as:  systemd-failure-notify <unescaped-unit-name>
  # Expects these environment variables to be set by the caller:
  #   NOTIFY_MODE           "system" or "user" — controls whether systemctl/
  #                          journalctl are invoked with --user
  #   NOTIFY_MAILTO          recipient address (required)
  #   NOTIFY_MAILFROM        From: address
  #   NOTIFY_SUBJECT_PREFIX  short tag prepended to the subject line
  #   NOTIFY_SENDMAIL        sendmail-compatible binary name or absolute path
  {
    packages.systemd-failure-notify = pkgs.writeShellApplication {
      name = "systemd-failure-notify";
      runtimeInputs = [pkgs.systemd pkgs.coreutils];
      text = ''
        UNIT="''${1:?systemd-failure-notify: missing unit name argument}"
        MODE="''${NOTIFY_MODE:-system}"
        MAILTO="''${NOTIFY_MAILTO:?NOTIFY_MAILTO not set}"
        MAILFROM="''${NOTIFY_MAILFROM:-$MAILTO}"
        SUBJECT_PREFIX="''${NOTIFY_SUBJECT_PREFIX:-[systemd]}"
        SENDMAIL="''${NOTIFY_SENDMAIL:-sendmail}"
        HOST="$(uname -n)"
        NOW="$(date -Is)"

        if [ "$MODE" = "user" ]; then
          STATUS="$(systemctl --user --no-pager --full status "$UNIT" 2>&1 || true)"
          LOGS="$(journalctl --user-unit="$UNIT" -n 50 --no-pager 2>&1 || true)"
        else
          STATUS="$(systemctl --no-pager --full status "$UNIT" 2>&1 || true)"
          LOGS="$(journalctl -u "$UNIT" -n 50 --no-pager 2>&1 || true)"
        fi

        {
          printf 'To: %s\n' "$MAILTO"
          printf 'From: %s\n' "$MAILFROM"
          printf 'Subject: %s %s failed on %s\n' "$SUBJECT_PREFIX" "$UNIT" "$HOST"
          printf '\n'
          printf 'Unit %s entered the failed state on %s at %s.\n\n' "$UNIT" "$HOST" "$NOW"
          printf -- '--- systemctl status ---\n%s\n\n' "$STATUS"
          printf -- '--- last 50 journal lines ---\n%s\n' "$LOGS"
        } | "$SENDMAIL" -t
      '';
    };
  };
}

{
  config,
  pkgs,
  ...
}: {
  # Most config taken from https://wiki.nixos.org/wiki/Uninterruptible_power_supply

  sops.secrets.ups-passwd = {};
  power.ups = {
    enable = true;
    mode = "standalone";
    ups."UPS-1" = {
      description = "CyberPower CP685AVRG 12V 7.2 Ah (replaced 29-Jun-24)";
      driver = "usbhid-ups";
      port = "auto";
      directives = [
        "offdelay = 60"
        "ondelay = 70"
        "lowbatt = 30"
        "ignorelb"
      ];
    };
    upsd = {
      listen = [
        {
          address = "127.0.0.1";
          port = 3493;
        }
        {
          address = "::1";
          port = 3493;
        }
      ];
    };
    users."nut-admin" = {
      passwordFile = config.sops.secrets.ups-passwd.path;
      upsmon = "primary";
    };
    upsmon.monitor."UPS-1" = {
      system = "UPS-1@localhost";
      powerValue = 1;
      user = "nut-admin";
      passwordFile = config.sops.secrets.ups-passwd.path;
      type = "primary";
    };
    upsmon.settings = {
      # This configuration file declares how upsmon is to handle
      # NOTIFY events.

      # POWERDOWNFLAG and SHUTDOWNCMD is provided by NixOS default
      # values

      # values provided by ConfigExamples 3.0 book
      NOTIFYMSG = [
        ["ONLINE" ''"UPS %s: On line power."'']
        ["ONBATT" ''"UPS %s: On battery."'']
        ["LOWBATT" ''"UPS %s: Battery is low."'']
        ["REPLBATT" ''"UPS %s: Battery needs to be replaced."'']
        ["FSD" ''"UPS %s: Forced shutdown in progress."'']
        ["SHUTDOWN" ''"Auto logout and shutdown proceeding."'']
        ["COMMOK" ''"UPS %s: Communications (re-)established."'']
        ["COMMBAD" ''"UPS %s: Communications lost."'']
        ["NOCOMM" ''"UPS %s: Not available."'']
        ["NOPARENT" ''"upsmon parent dead, shutdown impossible."'']
      ];
      NOTIFYFLAG = [
        ["ONLINE" "SYSLOG+WALL"]
        ["ONBATT" "SYSLOG+WALL"]
        ["LOWBATT" "SYSLOG+WALL"]
        ["REPLBATT" "SYSLOG+WALL"]
        ["FSD" "SYSLOG+WALL"]
        ["SHUTDOWN" "SYSLOG+WALL"]
        ["COMMOK" "SYSLOG+WALL"]
        ["COMMBAD" "SYSLOG+WALL"]
        ["NOCOMM" "SYSLOG+WALL"]
        ["NOPARENT" "SYSLOG+WALL"]
      ];
      # every RBWARNTIME seconds, upsmon will generate a replace
      # battery NOTIFY event
      RBWARNTIME = 216000;
      # every NOCOMMWARNTIME seconds, upsmon will generate a UPS
      # unreachable NOTIFY event
      NOCOMMWARNTIME = 300;
      # after sending SHUTDOWN NOTIFY event to warn users, upsmon
      # waits FINALDELAY seconds long before executing SHUTDOWNCMD
      # Some UPS's don't give much warning for low battery and will
      # require a value of 0 here for aq safe shutdown.
      FINALDELAY = 10;
    };
  };

  # copied from ConfigExamples 3.0 book, Appendix B.2.
  systemd.services.nut-delayed-ups-shutdown = {
    enable = true;
    environment = config.systemd.services.upsmon.environment;
    description = "Initiate delayed UPS shutdown";
    before = ["umount.target"];
    wantedBy = ["final.target"];
    serviceConfig = {
      Type = "oneshot";
      # need to use '-u root', or else permission denied
      ExecStart = ''${pkgs.nut}/bin/upsdrvctl -u root shutdown'';
      # must not use slice: if used, upsdrvctl will not run as a late
      # shutdown service
      # Slice = "";
    };
    unitConfig = {
      ConditionPathExists = config.power.ups.upsmon.settings.POWERDOWNFLAG;
      DefaultDependencies = "no";
    };
  };
}

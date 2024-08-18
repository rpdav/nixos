{config, pkgs, lib, secrets, userSettings, ... }:

let
## Set up notifications in case of failure
  borgbackupMonitor = { config, pkgs, lib, ... }: with lib; {
    key = "borgbackupMonitor";
    _file = "borgbackupMonitor";
    config.systemd.services = {
      "notify-problems@" = {
        enable = true;
        serviceConfig.User = "danbst";
        environment.SERVICE = "%i";
        script = ''
          export $(cat /proc/$(${pkgs.procps}/bin/pgrep "gnome-session" -u "$USER")/environ |grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          ${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
        '';
      };
    } // flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        unitConfig.OnFailure = "notify-problems@%i.service";
      ## Wait for network access
        preStart = lib.mkBefore ''
          # waiting for internet after resume-from-suspend
          until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do :; done
        '';
      }
    );

    # optional, but this actually forces backup after boot in case laptop was powered off during scheduled event
    # for example, if you scheduled backups daily, your laptop should be powered on at 00:00
    config.systemd.timers = flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        timerConfig.Persistent = lib.mkForce true;
      }
    );
  };

in {
  imports =
    [
      borgbackupMonitor
    ];

# This config assumes this machine's root user public key is copied to the borg server as /sshkeys/clients/$hostname. The server will create a backup directory under /backup/$hostname

## Extra root ssh config 
  programs.ssh.extraConfig = ''
    Host borg
      HostName 10.10.1.16
      User borg
  '';

## Local backup definition
  services.borgbackup.jobs."local" = {
    paths = [ "/persist/home/${userSettings.username}" ];
    exclude = [
      "/persist/home/${userSettings.username}/.thunderbird/${userSettings.username}/ImapMail"
      "/persist/home/${userSettings.username}/Nextcloud"
      "/persist/home/${userSettings.username}/.local/share/Steam/steamapps"
      "/persist/home/${userSettings.username}/.local/share/lutris"
      "/persist/home/${userSettings.username}/.local/share/protonmail"
    ];
    user = "root";
    repo = ("ssh://borg@borg/backup" + ("/" + config.networking.hostName));
    doInit = true;
    startAt = [ "daily" ];
#    preHook = placeholder for snapshotting/mounting command
#    postHook = placeholder for snapshot deletion/unmount
    encryption = {
      mode = "repokey-blake2";
      passphrase = "${secrets.borg.passphrase}"; #This is also in password manager under entry "Borg backup"
    };
    compression = "auto,lzma";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 12;
      yearly = 1;
    };
  };

}

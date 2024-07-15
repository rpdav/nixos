{config, pkgs, lib, secrets, systemSettings, ... }:
{

  fileSystems."/mnt/backup" = {
    device = "//10.10.1.17/secure/backups/nixbook";
    fsType = "cifs";
    options = [ "uid=ryan" "gid=users" "username=ryan" "password=${secrets.backup.password}" "noauto" "users" ];
  };

  services.borgbackup.jobs."nas-test" = {
    paths = [ "/persist/home/ryan/Documents" ];
    exclude = [
      "/persist/home/ryan/OpenTTD"
      "/persist/home/ryan/medical"
    ];
    user = "root";
    repo = ("root@10.10.1.17:/tank/backups" + ("/" + systemSettings.hostname + "/") + "./test");
    doInit = true;
    startAt = [ ]; #replace with daily or whatver. this is for manual running
##    preHook = optional snapshotting/mounting command
##    postHook = optional snapshot deletion/unmount
    encryption = {
      mode = "repokey-blake2";
      passphrase = "${secrets.borg.testpassphrase}";
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

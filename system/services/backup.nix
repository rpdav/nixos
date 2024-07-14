{config, lib, secrets, ... }:
{

  fileSystems."/mnt/backup" = {
    device = "//10.10.1.17/secure/backups/nixbook";
    fsType = "cifs";
    options = [ "username=ryan" "password=${secrets.backup.password}" "x-systemd.automount" "auto" "user" ];
  };

}

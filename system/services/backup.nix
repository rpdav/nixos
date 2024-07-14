{config, pkgs, lib, secrets, ... }:
{

  fileSystems."/mnt/backup" = {
    device = "//10.10.1.17/secure/backups/nixbook";
    fsType = "cifs";
    options = [ "uid=ryan" "gid=users" "username=ryan" "password=${secrets.backup.password}" "noauto" "users" ];
  };

}

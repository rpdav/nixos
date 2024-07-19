{config, pkgs, lib, secrets, systemSettings, userSettings, ... }:
{

# This config assumes this machine's root user public key is copied to the borg server as /sshkeys/clients/$hostname. The server will create a backup directory under /backup/$hostname

## Extra root ssh config 
  programs.ssh.extraConfig = ''
    Host borg
      HostName 10.10.1.17
      User borg
      Port 2222
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
    repo = ("ssh://borg@10.10.1.17:2222/backup" + ("/" + systemSettings.hostname));
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

## Gave up on the remote backup section below. Couldn't get it to reliably mount before backup. Might try making a manual systemd timer with own script.

### Create rclone mount target on boot. Could not get this to work in borg preHook script
#  systemd.tmpfiles.rules = [
#    "d /mnt/rclone/${systemSettings.hostname} 0755 root root"
#  ];
#
### Remote backup definition
#  services.borgbackup.jobs."remote-test" = {
#    paths = [ "/persist/home/${userSettings.username}/Documents" ];
##    exclude = [
##      "/persist/home/${userSettings.username}/.thunderbird/${userSettings.username}/ImapMail"
##      "/persist/home/${userSettings.username}/Nextcloud"
##    ];
#    user = "root";
#    repo = "/mnt/rclone/${systemSettings.hostname}-test";
#    doInit = true;
#    startAt = [ "weekly" ];
#    preHook = ''
#      echo "Mounting remote"
#      ${pkgs.rclone}/bin/rclone mount B2:${secrets.rclone.bucket}/${systemSettings.hostname}-test /mnt/rclone/${systemSettings.hostname}-test --daemon --config /home/${userSettings.username}/.config/rclone/rclone.conf
#      echo "Starting backup..."
#    '';
##    postHook = ''
##      echo "Unmounting remote"
##      ${pkgs.umount}/bin/umount /mnt/rclone/${systemSettings.hostname}-test 
##    '';
#    encryption = {
#      mode = "repokey-blake2";
#      passphrase = "${secrets.borg.passphrase}"; #This is also in password manager under entry "Borg backup"
#    };
#    compression = "auto,lzma";
#    prune.keep = {
#      weekly = 4;
#      monthly = 12;
#      yearly = 1;
#    };
#  };

}

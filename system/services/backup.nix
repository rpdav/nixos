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
    ];
    user = "root";
    repo = ("borg@borg:/backup" + ("/" + systemSettings.hostname));
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

## Remote backup definition
  services.borgbackup.jobs."remote-test" = {
    paths = [ "/persist/home/${userSettings.username}/Documents" ];
    exclude = [
#      "/persist/home/${userSettings.username}/.thunderbird/${userSettings.username}/ImapMail"
#      "/persist/home/${userSettings.username}/Nextcloud"
    ];
    user = "root";
    repo = "/mnt/backup/${systemSettings.hostname}";
    doInit = true;
    startAt = [ "weekly" ];
    preHook = ''
      mkdir /mnt/backup/${systemSettings.hostname} && rclone mount B2:${secrets.rclone.bucket}/${systemSettings.hostname} /mnt/backup/${systemSettings.hostname} --config /home/${userSettings.username}/.config/rcone/rclone.conf
    '';
    postHook = ''
      rclone umount /mnt/backup/${systemSettings.hostname} && rm -r /mnt/backup
    '';
    encryption = {
      mode = "repokey-blake2";
      passphrase = "${secrets.borg.passphrase}"; #This is also in password manager under entry "Borg backup"
    };
    compression = "auto,lzma";
    prune.keep = {
      weekly = 4;
      monthly = 12;
      yearly = 1;
    };
  };

}

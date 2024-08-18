{config, pkgs, lib, secrets, userSettings, ... }:
{

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

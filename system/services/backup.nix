{config, pkgs, lib, secrets, systemSettings, ... }:
{

## Extra root ssh config 
  programs.ssh.extraConfig = ''
    Host borg
      HostName 10.10.1.17
      User borg
      Port 2222
  '';

## Backup definition
  services.borgbackup.jobs."nas-test" = {
    paths = [ "/persist/home/ryan/Documents" ];
    exclude = [
      "/persist/home/ryan/Documents/OpenTTD"
      "/persist/home/ryan/Documents/medical"
    ];
    user = "root";
    repo = ("borg@borg:/backup" + ("/" + systemSettings.hostname)); #Borg server creates directories at /backup/<pubkey> for all pubkeys in /sshkeys/clients/<pubkey>
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

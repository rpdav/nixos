{config, pkgs, userSettings, ... }:
{
  sops.secrets = {
    "${userSettings.username}/sshkey".path = "/home/${userSettings.username}/.ssh/id_ed25519";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host nas
      	HostName 10.10.1.17
      	User root
      	Port 22
      
      Host pi
      	HostName 10.10.1.10
      	User pi
      	Port 22
      
      Host vps
      	HostName 10.100.94.1 #wireguard IP
      	User root
      	Port 44422
      
      Host pve
      	Hostname 10.10.1.18
      	User root
      	Port 22

      Host borg
        Hostname 10.10.1.16
        User borg
    '';
  };

}

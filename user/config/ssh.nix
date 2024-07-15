{config, pkgs, ... }:
{
  
  programs.ssh = {
    enable = true;
    userKnownHostsFile = "/persist/home/ryan/.ssh/known_hosts";
    extraConfig = ''
      Host nas
      	HostName 10.10.1.17
      	User root
      	Port 22
      
      Host pi
      	HostName 10.10.1.10
      	User pi
      	Port 22
      
      Host vps.***REMOVED*** vps
      	HostName 10.100.94.1 #wireguard IP
      #	HostName 170.187.148.177 #direct IP
      	User root
      	Port 44422
      
      Host pve
      	Hostname 10.10.1.18
      	User root
      	Port 22
    '';
  };

}

{
  pkgs,
  systemOpts,
  lib,
  ...
}: {
  # Create impermanent directory
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    ports = [22];
    settings.PasswordAuthentication = false;
    hostKeys = [
      {
        comment = "server key";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };

  programs.ssh.extraConfig = ''
    Host nas
      HostName 10.10.1.17
      User ryan
      Port 22

    Host pi
      HostName 10.10.1.10
      User pi
      Port 22

    Host vps
      Hostname 172.233.209.173
      User ryan

    Host borg
      Hostname 10.10.1.17
      Port 2222
      User borg

    Host testbox
      Hostname 10.10.1.18
      User ryan

    Host testvm
      Hostname 192.168.122.224
      User root

    Host gitea.dfrp.xyz
      User git
      Port 2223

    Host github.com
      User git
  '';

  # Enable remote passwordless sudo
  security.pam.services.sudo = {config, ...}: {
    rules.auth.rssh = {
      order = config.rules.auth.ssh_agent_auth.order - 1;
      control = "sufficient";
      modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
      settings.authorized_keys_command = pkgs.writeShellScript "get-authorized-keys" ''
        cat "/etc/ssh/authorized_keys.d/$1"
      '';
    };
  };
}

{ config, ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PasswordAuthentication = false;
    hostKeys = [
      {
        comment = "key comment";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };
}

{ config, secrets, ... }:
{
  sops.secrets = {
    "wireguard/home/privateKey" = { };
  };

  networking.wg-quick.interfaces = {
    home = {
      address = [ "10.10.10.3/32" ];
      dns = [ "10.10.1.1" ];
      privateKeyFile = "${config.sops.secrets."wireguard/home/privateKey".path}";
      peers = [
        { #router 
          publicKey = "gy5zJPgMgC5ZBLScN7Wqiu0KXNL+rYGAnYs7c7wS72g=";
          allowedIPs = [ "10.10.10.0/32" "10.10.1.0/24" "10.10.30.0/24" ];
          endpoint = "${secrets.wireguard.home.endpoint}:51820";
        }
      ];
    };
  };
}

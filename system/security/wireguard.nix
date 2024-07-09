{ config, secrets, ... }:

{

  networking.wireguard.interfaces = {
    home = {
      ips = [
        "10.10.10.5/32"
      ];
      dns = "10.10.1.1";
      peers = [
        {
          allowedIPs = [
            "10.10.10.1/32 10.10.1.1/24 10.10.30.1/24"
          ];
          endpoint = "${secrets.wireguard.endpoint}:51820";
          publicKey = "gy5zJPgMgC5ZBLScN7Wqiu0KXNL+rYGAnYs7c7wS72g=";
        }
      ];
      privateKey = "${secrets.wireguard.privateKey}";
    };
  };
}

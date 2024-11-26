{
  config,
  secrets,
  ...
}: {
  sops.secrets = {
    "${config.networking.hostName}/home/wgPrivateKey" = {};
    "${config.networking.hostName}/vps/wgPrivateKey" = {};
  };

  networking.wg-quick.interfaces = {
    home = {
      autostart = false;
      address = ["10.10.10.3/32"];
      dns = ["10.10.1.1"];
      privateKeyFile = "${config.sops.secrets."${config.networking.hostName}/home/wgPrivateKey".path}";
      peers = [
        {
          #router
          publicKey = "gy5zJPgMgC5ZBLScN7Wqiu0KXNL+rYGAnYs7c7wS72g=";
          allowedIPs = ["10.10.10.0/32" "10.10.1.0/24" "10.10.30.0/24"];
          endpoint = "${secrets.wireguard.home.endpoint}:51820";
        }
      ];
    };
    vps = {
      autostart = false;
      address = ["10.100.94.11/32"];
      privateKeyFile = "${config.sops.secrets."${config.networking.hostName}/vps/wgPrivateKey".path}";
      peers = [
        {
          publicKey = "K+ROdMPjS4eUA804orSk9Vl8NryfvaiWUfPzqBEFbVw=";
          allowedIPs = ["10.36.7.11/32" "10.100.94.0/24"];
          endpoint = "${secrets.wireguard.vps.endpoint}:51820";
        }
      ];
    };
  };
}

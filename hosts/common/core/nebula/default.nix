{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) hostName;
  isLighthouse =
    if hostName == "vps"
    then true
    else false;
in {
  ### Host IPs ###
  # vps: 10.112.1.1
  # fw13: 10.112.1.2
  # nas: 10.112.1.3

  # install binaries
  environment.systemPackages = [pkgs.nebula];

  # decrypt host key
  sops.secrets."nebula/${hostName}.key".owner = "nebula-mesh";

  services.nebula.networks."mesh" = {
    enable = true;

    # pull key and certs
    key = config.sops.secrets."nebula/${hostName}.key".path;
    cert = ./certs/${hostName}.crt;
    ca = ./certs/ca.crt;

    # lighthouse config
    inherit isLighthouse;
    # only apply next 2 lines for non-lighthouse hosts
    lighthouses = mkIf (!isLighthouse) ["10.112.1.1"];
    staticHostMap = mkIf (!isLighthouse) {
      "10.112.1.1" = ["${secrets.vps.ip}:4242"];
    };

    # firewall rules
    firewall = {
      outbound = [
        {
          port = "any";
          proto = "any";
          host = "any";
        }
      ];
      inbound = [
        {
          port = "any";
          proto = "icmp";
          host = "any";
        }
      ];
    };
    settings = {
      punchy = {
        punch = true;
      };
    };
  };
}

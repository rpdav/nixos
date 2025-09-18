{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  inherit (config.networking) hostName;
in {
  ##### Host IPs #####
  # vps: 10.112.1.1  #
  # fw13: 10.112.1.2 #
  # nas: 10.112.1.3  #

  # install binaries
  environment.systemPackages = [pkgs.nebula];

  # decrypt host key and make it readable to the service
  sops.secrets."nebula/${hostName}.key".owner = config.systemOpts.primaryUser;

  networking.firewall.allowedUDPPorts = [4242];
  #  services.nebula.networks."mesh" = {
  #    enable = true;
  #
  #    # pull key and certs
  #    key = config.sops.secrets."nebula/${hostName}.key".path;
  #    cert = ./certs/${hostName}.crt;
  #    ca = ./certs/ca.crt;
  #
  #    # firewall rules
  #    firewall = {
  #      outbound = [
  #        {
  #          port = "any";
  #          proto = "any";
  #          host = "any";
  #        }
  #      ];
  #      inbound = [
  #        {
  #          port = "any";
  #          proto = "icmp";
  #          host = "any";
  #        }
  #        {
  #          port = "443";
  #          proto = "tcp";
  #          host = "any";
  #        }
  #        {
  #          port = "22";
  #          proto = "tcp";
  #          host = "any";
  #        }
  #      ];
  #    };
  #
  #    # other settings
  #    settings = {
  #      punchy = {
  #        punch = true;
  #      };
  #    };
  #  };
}

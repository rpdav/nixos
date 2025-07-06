{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.virtualisation.oci-containers.proxy-conf = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        container = mkOption {
          type = types.str;
          description = "Name of the container hostname or IP. Must be reachable by swag";
          example = "nextcloud";
        };
        subdomain = mkOption {
          type = types.str;
          description = "Subdomain as in <subdomain>.mydomain.com";
          example = "cloud";
        };
        port = mkOption {
          type = types.port;
          example = 8080;
          description = "Container port (not host-mapped port)";
          default = 80;
        };
        protocol = mkOption {
          type = types.enum ["http" "https"];
          example = "https";
          description = "Protocol (either http or https)";
          default = "http";
        };
      };
    });
  };
  config = {
  };
}

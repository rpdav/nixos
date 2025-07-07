{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.virtualisation.oci-containers.proxy-conf;
in {
  options.virtualisation.oci-containers.proxy-conf = mkOption {
    type = types.attrsOf (
      types.submodule ({name, ...}: {
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
      })
    );
  };
  config = {
    environment.etc.namehere = {
      target = "selfhosting/proxy-conf";
      text = "boilerplate";
    };
    #    systemd.tmpfiles.settings."01-proxy-confs" = {
    #      "/run/selfhosting/proxy-confs/test.subdomain.conf" = {
    #        "f+" = {
    #          group = "users";
    #          user = "ryan";
    #          mode = "0700";
    #          argument = ''
    #            server {
    #                listen 443 ssl;
    #                listen [::]:443 ssl;
    #                server_name ${cfg.name.subdomain}.*;
    #                include /config/nginx/ssl.conf;
    #                client_max_body_size 0;
    #                location / {
    #                    include /config/nginx/proxy.conf;
    #                    include /config/nginx/resolver.conf;
    #                    set $upstream_app ${cfg.name.container};
    #                    set $upstream_port ${cfg.name.port};
    #                    set $upstream_proto ${cfg.name.protocol};
    #                    proxy_pass $upstream_proto://$upstream_app:$upstream_port;
    #                }
    #            }
    #          '';
    #        };
    #      };
    #    };
  };
}

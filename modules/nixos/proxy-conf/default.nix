{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types flatten mapAttrsToList;
  cfg = config.virtualisation.oci-containers.proxy-conf;
in {
  options.virtualisation.oci-containers.proxy-conf = mkOption {
    type = types.attrsOf (
      types.submodule ({name, ...}: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };
          container = mkOption {
            type = types.str;
            description = "Name of the container hostname or IP. Must be reachable by swag";
            example = "nextcloud";
            default = name;
          };
          subdomain = mkOption {
            type = types.str;
            description = "Subdomain as in <subdomain>.mydomain.com";
            default = name;
            example = "cloud";
          };
          port = mkOption {
            type = types.str;
            example = "8080";
            description = "Container port (not host-mapped port)";
            default = "80";
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
    systemd.tmpfiles.rules = flatten (mapAttrsToList (
        key: val: let
          # For example: create a directory with the given name and mode
          rule = "f+ /run/selfhosting/${val.name}.subdomain.conf 0700 ryan users - set $upstream_app ${val.container}";
        in [rule]
      )
      cfg);
  };
  #    systemd.tmpfiles.settings."01-proxy-confs" = {
  #      "/run/selfhosting/proxy-confs/test.subdomain.conf" = {
  #        "f+" = {
  #          group = "users";
  #          user = "ryan";
  #          mode = "0700";
  #        };
  #      };
  #    };
  # };
  #        proxyArg = ''
  #          server {
  #              listen 443 ssl;
  #              listen [::]:443 ssl;
  #              server_name ${cfg.subdomain}.*;
  #              include /config/nginx/ssl.conf;
  #              client_max_body_size 0;
  #              location / {
  #                  include /config/nginx/proxy.conf;
  #                  include /config/nginx/resolver.conf;
  #                  set $upstream_app ${cfg.container};
  #                  set $upstream_port ${cfg.port};
  #                  set $upstream_proto ${cfg.protocol};
  #                  proxy_pass $upstream_proto://$upstream_app:$upstream_port;
  #              }
  #          }
  #        '';
}

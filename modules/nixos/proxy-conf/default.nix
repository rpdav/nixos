{
  lib,
  config,
  ...
}: let
  inherit (lib) mkMerge mkOption types mapAttrs';
  proxyConf = services:
    mapAttrs' (name: cfg: {
      name = "${name}.subdomain.conf";
      value = let
        proxyArg = ''
          server {
              listen 443 ssl;
              listen [::]:443 ssl;
              server_name ${cfg.subdomain}.*;
              include /config/nginx/ssl.conf;
              client_max_body_size 0;
              location / {
                  include /config/nginx/proxy.conf;
                  include /config/nginx/resolver.conf;
                  set $upstream_app ${cfg.container};
                  set $upstream_port ${cfg.port};
                  set $upstream_proto ${cfg.protocol};
                  proxy_pass $upstream_proto://$upstream_app:$upstream_port;
              }
          }
        '';
      in "f+ /run/selfhosting/${name} 0700 ryan users - ${proxyArg}";
    })
    services;
in {
  options.virtualisation.oci-containers.proxy-conf = mkOption {
    type = types.attrsOf (
      types.submodule ({name, ...}: {
        options = {
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
    systemd.tmpfiles.rules = mkMerge [
      (proxyConf config.virtualisation.oci-containers.proxy-conf)
    ];
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
}

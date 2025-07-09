{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.virtualisation.oci-containers.proxy-conf;
in {
  # Define submodule options
  options.virtualisation.oci-containers.proxy-conf = mkOption {
    default = {};
    type = types.attrsOf (
      types.submodule ({name, ...}: {
        options = {
          enable = lib.mkEnableOption "Enable proxy config module";
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
    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (
        key: val: let
          textPort = toString val.port;
          # Define the proxy config as a multi-line string and convert to single-line with newlines
          proxyArg = builtins.replaceStrings ["\n"] ["\\n"] ''
            server {
                listen 443 ssl;
                listen [::]:443 ssl;
                server_name ${val.subdomain}.*;
                include /config/nginx/ssl.conf;
                client_max_body_size 0;
                location / {
                    include /config/nginx/proxy.conf;
                    include /config/nginx/resolver.conf;
                    set $upstream_app ${val.container};
                    set $upstream_port ${textPort};
                    set $upstream_proto ${val.protocol};
                    proxy_pass $upstream_proto://$upstream_app:$upstream_port;
                }
            }
          '';
          # Define tmpfile rule to delete the config when tmpfiles runs (otherwise changes don't get written)
          deleteRule = "r ${config.serviceOpts.proxyDir}/${val.name}.subdomain.conf";
          # Define tmpfile rule to write the config based on proxyArg and serviceOpts options
          createRule = "f+ ${config.serviceOpts.proxyDir}/${val.name}.subdomain.conf 0600 ${config.serviceOpts.dockerUser} users - ${proxyArg}";
        in [
          # Make sure file is deleted first, then recreated
          (lib.mkBefore deleteRule)
          createRule
        ]
      )
      cfg);
  };
}

{
  config,
  pkgs,
  ...
}: let
  inherit (config.serviceOpts) dockerUser dockerDir;
in {
  networking.firewall = {
    allowedTCPPorts = [8090];
  };

  systemd.services.beszel-hub = {
    description = "Beszel Hub";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 3;
      User = "${dockerUser}";
      WorkingDirectory = "${dockerDir}/beszel-hub";
      ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http \"0.0.0.0:8090\"";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."beszel" = {
    container = "10.10.1.17";
    subdomain = "status";
    port = 8090;
    protocol = "http";
  };
}

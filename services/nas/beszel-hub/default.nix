{
  serviceOpts,
  pkgs,
  ...
}: {
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
      User = "${serviceOpts.dockerUser}";
      WorkingDirectory = "${serviceOpts.dockerDir}/beszel-hub";
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

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/beszel-hub 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/beszel-hub - ${serviceOpts.dockerUser} users"
  ];
}

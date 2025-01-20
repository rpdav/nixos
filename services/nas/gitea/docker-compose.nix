# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  serviceOpts,
  uptix,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."gitea" = {
    image = uptix.dockerImage "gitea/gitea";
    environment = {
      "USER_GID" = "1000";
      "USER_UID" = "1000";
    };
    volumes = [
      "${serviceOpts.dockerDir}/gitea/config:/data:rw"
      "/etc/localtime:/etc/localtime:ro"
    ];
    ports = [
      "2223:22/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=gitea"
      "--network=proxynet"
    ];
  };
  systemd.services."docker-gitea" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    partOf = [
      "docker-compose-gitea-root.target"
    ];
    wantedBy = [
      "docker-compose-gitea-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-gitea-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}

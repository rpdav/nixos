{pkgs, ...}: {

  imports = [
    ./swag
    ./beszel-agent
  ];
  # create proxynet network
  systemd.services."docker-network-proxynet" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f proxynet";
    };
    script = ''
      docker network inspect proxynet || docker network create proxynet
    '';
    after = ["docker.service"];
    wantedBy = ["multi-user.target"];
  };
}

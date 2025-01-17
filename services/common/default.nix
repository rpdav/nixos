{pkgs, ...}: {

  imports = [
    ./swag
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

  # create dbnet network
  systemd.services."docker-network-dbnet" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f dbnet";
    };
    script = ''
      docker network inspect dbnet || docker network create dbnet
    '';
    after = ["docker.service"];
    wantedBy = ["multi-user.target"];
  };
}

{inputs, ...}: {
  flake.serviceModules.swag = {
    config,
    pkgs,
    ...
  }: {
    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."swag" = {};

    # Secrets
    sops.secrets."selfhosting/swag/cloudflareToken" = {
      owner = config.users.users.${config.serviceOpts.dockerUser}.name;
      sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      restartUnits = ["docker-swag.service"];
    };
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
  };
}

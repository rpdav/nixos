{self, ...}: {
  flake.nixosModules.docker = {
    config,
    lib,
    ...
  }: let
    inherit (config) systemOpts serviceOpts;
    inherit (self.modules.nixos) proxyConfs containerMounts;
  in {
    imports = [
      proxyConfs
      containerMounts
    ];

    # Create impermanent directory
    environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
      directories = [
        "/var/lib/docker"
      ];
    };

    # Enable docker
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
      #podman-only config below in case I switch back
      #    dockerCompat = true;
      #    defaultNetwork.settings = {
      #      # Required for container networking to be able to use names.
      #      dns_enabled = true;
      #    };
    };

    virtualisation.oci-containers.backend = "docker";

    # Open firewall port for dns resolution
    networking.firewall = {
      allowedUDPPorts = [53];
    };

    # Add user to docker group
    users.users.${serviceOpts.dockerUser} = {
      extraGroups = ["docker"];
    };
  };
}

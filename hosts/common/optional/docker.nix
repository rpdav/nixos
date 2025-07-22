{
  inputs,
  pkgs,
  config,
  lib,
  configLib,
  ...
}: let
  inherit (config) systemOpts serviceOpts;
in {
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

  imports = [(inputs.uptix.nixosModules.uptix (configLib.relativeToRoot "./uptix.lock"))];

  virtualisation.oci-containers.backend = "docker";

  # Open firewall port for dns resolution
  networking.firewall = {
    allowedUDPPorts = [53];
  };

  # Add user to docker group
  users.users.${serviceOpts.dockerUser} = {
    extraGroups = ["docker"];
  };

  environment.systemPackages = with pkgs; [
    oxker
    lazydocker
    beszel
    jq
    (writeShellScriptBin "dup" "sudo systemctl restart docker-$1.service")
    (writeShellScriptBin "ddown" "sudo systemctl stop docker-$1.service")
    (writeShellScriptBin "dcup" "sudo systemctl restart docker-compose-$1-root.target")
    (writeShellScriptBin "dcdown" "sudo systemctl stop docker-compose-$1-root.target")
    (writeShellScriptBin "dcpull" "docker pull $(sudo docker inspect $1 | jq -r .[0].ImageName)")
    (writeShellScriptBin "appdata" "cd ${serviceOpts.dockerDir}/$1")
    (writeShellScriptBin "dtail" "docker logs -tf -n 50 $1")
    (writeShellScriptBin "dexec" "docker exec -it $1 /bin/bash")
  ];
}

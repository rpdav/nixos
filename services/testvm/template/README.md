Use these templates to bring a proxied, selfhosted service online using systemd tmpfiles and oci containers. Any fields that need updated are flagged like `[CONTAINER]`.

1. Obtain an upstream copy of docker-compose.yml if available
1. Update this docker-compose.yml with container, volume, port, network, etc details
1. Run nix run github:aksiksi/compose2nix -- -write_nix_setup=false -runtime docker -project=[CONTAINER]
1. Update the generated docker-compose.nix
    1. Properly use serviceOpts custom opts
    1. Add uptix.dockerImage function to image name
    1. Add serviceOpts and uptix as variables
1. Update default.nix with container, subdomain, and port information.
1. Update opnSense host overrides with new subdomain

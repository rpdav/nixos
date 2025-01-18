Use these templates to bring a proxied, selfhosted service online using systemd tmpfiles and oci containers. Any fields that need updated are flagged like `[CONTAINER]`.

1. Obtain an upstream copy of docker-compose.yml if available
1. Update this docker-compose.yml with container, volume, port, network, etc details
1. Run nix run github:aksiksi/compose2nix -- -write_nix_setup=false -runtime docker -project=[CONTAINER]
1. Update the generated docker-compose.nix
    1. Properly use serviceOpts custom opts
    1. Add uptix.dockerImage function to image name
    1. Add serviceOpts and uptix as variables
    1. Add secrets if needed (see section below)
1. Update default.nix with container, subdomain, and port information.
1. Update opnSense host overrides with new subdomain


## Secret environment variables
1. Put the contents of the secrets env file into sops; push and pull down the secrets repo
1. Add the secrets binding to `default.nix`
1. Remove those environment bindings from `docker-compose.nix`
1. After running `compose2nix` add a reference to the secret env file:
```code
    environmentFiles = [
      "/run/secrets/path/to/env"
    ];
```

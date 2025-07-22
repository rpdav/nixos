Use these templates to bring a proxied, selfhosted service online using systemd tmpfiles and oci containers. Any fields that need updated are flagged like `[CONTAINER]`.

1. Obtain an upstream copy of docker-compose.yml if available
1. Update this docker-compose.yml with container, volume, port, network, etc details
1. Run nix run github:aksiksi/compose2nix -- -write_nix_setup=false -runtime docker -project=[CONTAINER]
1. Update the generated docker-compose.nix (see cheat sheet section) to:
    1. Properly use serviceOpts custom opts
    1. Add uptix.dockerImage function to image name
    1. Add serviceOpts and uptix as module arguments
    1. Add secrets if needed (see section below)
1. Update default.nix with container, subdomain, and port information.
1. Update router host overrides with new subdomain

## Command cheat sheet
Use these vim commands after running compose2nix to replace custom option placeholders from the yml file.
```code
# assign host-specific docker appdata storage directory
:%s-/config\.serviceOpts\.dockerDir-${config.serviceOpts.dockerDir}-g
# add uptix function to manage container updates
:%s-image = -image = uptix.dockerImage -g
# replace timezone env var
:%s-config\.systemOpts\.timezone-${config.systemOpts.timezone}-g
```

## Secret environment variables
1. Put the contents of the secrets env file into sops; push and pull down the secrets repo
1. Add the secrets binding to `default.nix`
1. Remove those environment bindings from `docker-compose.nix`
1. After running `compose2nix` add a reference to the secret env file in the config for the container that requires it:
```code
    environmentFiles = [
      "/run/secrets/path/to/env"
    ];
```


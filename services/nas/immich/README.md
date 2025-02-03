## Updates

The compose file from https://immich.app recommends version-pinning redis and postgres. So those containers are not managed by uptix. Check immich's release notes to see when new database versions are supported

## Environment variables and secrets

This service has a `.env` file that is referenced by multiple containers in the compose file. The postgres, ml, and server containers also need the database password but assign different variable names to it. To work with this, starting with the default `docker-compose.yml` and `.env` files from immich.app:

1. Remove references to the postgres/db password in `docker-compose.yml` and in `.env`.
2. Create 2 sops entries for env files structured like this:
```code
selfhosting:
    immich:
        env-app: |
            DB_PASSWORD=changeme
        env-db: |
            POSTGRES_PASSWORD=changeme
```
3. run `compose2nix -write_nix_setup=false -runtime docker -project=immich -output=docker-compose.nix -env_files .env -include_env_files=true`
4. Make the usual updates to `docker-compose.nix` for the docker appdata directory and uptix container management.
5. Add to the server and ml container configs:
```code
    environmentFiles = [
      "/run/secrets/selfhosting/immich/env-app"
    ];
```
6. Add to the postgres container config:
```code
    environmentFiles = [
      "/run/secrets/selfhosting/immich/env-db"
    ];
```

This puts a redundant entry in sops but makes it easier to run compose2nix because it will complain if you assign a variable of `POSTGRES_PASSWORD=${DB_PASSWORD} like the default config due to the missing entry in the .env file.

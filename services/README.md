# Selfhosted Services

I run most of my selfhosted services using containers. Some services could be run as native nix modules like nginx and nextcloud, but I'm sticking with containers right now for a couple reasons:

1. My first goal is to transition my VPS and NAS over to Nixos and they exclusively use containers
2. I'm much more familiar with containers and compose

After getting everything transitioned, I may look into transitioning to Nixos modules.

## Docker vs Podman

This config uses docker. Podman is the default on Nixos but it currently can't be run rootless easily. This may get fixed in [this PR](https://github.com/NixOS/nixpkgs/pull/368565). Rootless is the main selling point for podman for me, so for now, docker will be used because it lets the user do some container operations (e.g. `ps` and `logs`) without sudo.

In case I ever switch to rootless, I currently have a designated docker user (usually the default user) to own the appdata folders to make it easier to implement down the road.

Note that if you switch between docker and podman, they handle some things differently. For instance, when switching from podman to docker, `swag` lost dns resolution because it wrote the podman default (`10.89.0.1`) to `/config/nginx/resolver.conf` whereas docker uses `127.0.0.11`. If switching, it is worth considering just rebuilding all appdata in case there are other differences in there somewhere.

## services/\<host\>/\<name\>/default.nix

This file contains any service-related config that isn't in `docker-compose.nix`.

`default.nix` uses a lot of `systemd.tmpfiles.rules`. The nix method declaratively handling files by writing to `/nix/store` and symlinking doesn't work with containers since they can't follow the symlinks (unless you also mount the entire store, I guess). Instead, regular files or directories have to be created. `tmpfiles` works well for this. Contrary to the name, `tmpfiles` works great for making non-temporary files and folders anywhere in the filesystem. See [here](https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html) for rule formatting.

### Volume creation and ownership

I prefer to create manual directories to pass through as volume mounts to containers. Any directories needed for the service are created using a `tmpfiles` d rule.

When reinstalling, `nixos-anywhere` can copy files over and will preserve rwx permissions but changes ownership to root. If a container is not run as root, this will cause problems. So a `tmpfiles` Z rule is used to recursively change ownership of each directory to the assigned docker user.

When `tmpfiles` creates a directory owned by a user, if parent directories also need to be created, they will be owned by root. So a service's main directory will be owned by root but the subfolders with individual docker volume mounts will be owned by the docker user. Keep this in mind when designing volume mounts (see [example](#proxy-configuration) below).

### Proxy configuration

For webapps that need to run through my reverse proxy (`swag`), there is a `let/in` binding to create a proxy config and place it in `swag`'s `proxy-confs` folder.

The `swag` service has volume mounts for `config` and `proxy-confs`. `proxy-confs` is just a subfolder of the former at `config/nginx/proxy-confs`. I mount it separately because, as noted above, if tmpfiles places a proxy config at `swag/config/nginx/proxy-confs`, it may create `swag/config/nginx` with root ownership, which may prevent swag from writing to it.

## services/\<host\>\<name\>/docker-compose.nix

### compose2nix
`docker-compose.nix` is created using [`compose2nix`](https://github.com/aksiksi/compose2nix). It takes a standard `docker-compose.yml` file and converts it to a nix `virtualisation.oci-containers` configuration. It also creates systemd services for bringing up the container(s) and any needed networks.

Some post-creation edits are needed to add in secrets and custom options (e.g. `serviceOpts.dockerDir` and `serviceOpts.dockerUser`). I use custom options here since different hosts use different users and appdata directories.

I keep `docker-compose.yml` around in case any upstream edits are made by the image maintainers. If edits are needed, just rerun `compose2nix` to regenerate `docker-compose.nix`. It will overwrite your post-generation edits but it's easy to pick out which edits you want to keep vs discard using git diffs.

### uptix

I use [uptix](https://github.com/luizribeiro/uptix) to manage container updates. It creates a version-pinned `uptix.lock` file in the root of the repo much like flake.lock. This lock file determines the version of the image that is assigned to the container.

The lock file is created by running the `uptix` binary, but by default the binary will create the lock file in the current working directory. Be sure to only run it in the root directory or use a `justfile` to do this automatically.

## Docker secrets

Since symlinks don't work with docker, secrets need to be mounted directly to `/run/secrets/foo/bar`.
I am running a multi-host nixos flake. My main repo is in github at rpdav/nixos. I also have a private secrets repo at rpdav/nix-secrets. I want to automate weekly flake updates and tests using github actions on the main repo. The nix-secrets repo contains sops-nix files as well as some unencrypted private information in nix-secrets/flake.nix, such as email addresses. These are used throughout the main nixos repo, so the runner **will** need access to the private repo, but not to the sops decryption keys. I have a github access token already stored as an action secret.

I would like to tackle this in 2 phases; first to get basic automated builds, checks, and PRs up and running, and second to implement a binary cache. Deployment is out of scope for this project; I will handle deployment manually for now assuming tests pass. If there is a better way to accomplish this than what I'm proposing below, I'm open to suggestions. I am also open to using marketplace actions to keep my runner's config simpler.

Phase 1:

Write a github action that will do the following things automatically on a weekly basis:
1. install nix and any other dependencies
2. clone my main repo and create/checkout an update branch
3. run `nix flake update`
4. run `nix run github:luizribreiro#uptix -- update` to update uptix.lock (like flake.lock but for containers)
5. run nix flake check
6. If checks all pass, create a PR to merge the updated lock files into `main`

Phase 2:

This will involve setting up a binary cache on my `vps` host (already in my nix config). I'm less sure about what will be needed to implement this but this is what I'm thinking:
1. Create an atticd module to run a binary cache. My VPS has a reverse proxy, so I can put atticd behind it easily.
2. The cache will be backed by backblaze B2 storage. I have some buckets on B2 already; mostly connecting via rclone.
3. The binary cache will be private, so I will need access tokens to allow the github runner to access it.
4. Configure the runner to push any newly built derivations up to the atticd binary cache
5. Configure my main repo to use the extra binary cache to take advantage of those builds. This should greatly reduce the number of builds I do locally.

Response:
OK a couple notes and questions:
1. Good point about `nix flake check` not building - adding the explicit build was appropriate
2. You are right about the uptix repo typo. But I confirmed that the `update` subcommand is required.
3. My secrets input is `github:rpdav/nix-secrets` so I will be using a PAT. Please update the appropriate sections accordingly.
4. Most of my hosts are x86_64, but I do have one aarch64 host `retropi`. It is important that this host be built. Can this single runner handle both architectures? And would you recommend doing emulation or doing a separate job for the other architectures?

Phase 2:
This time it worked successfully. Let's move on to phase 2. But first a few questions:
1. Does atticd listen on an http(s) port? If so, I already have a reverse proxy on `vps` which handles ssl termination; I can handle connecting it to atticd. I just need to know which port to connect it to. I will use an endpoint of `nix.dfrp.xyz`.
2. I run an impermanent setup on `vps`. Please advise if there are any state directories (other than the S3 backend) that would need persistent storage


Phase 2 2nd response:

For `attic` let's stick with the native NixOS service. 

> The swag container definition for vps, mainly which Docker network it's on, or whether it uses host networking.

The `swag` container does not use host networking. It uses a custom network called `proxynet` to allow name resolution to other containerized services. 

> An example of how proxyConf is used, and whether it can point at something other than a container name. If not, I'll write the nginx conf a different way.

I have some proxy configs for native nixos services on my nas that are able to point to the docker host. I just use the host's local IP as the "container". Not sure if that would work with the vps since it only has a public IP? I'm unfamiliar with proxying to a docker gateway, but am open to doing it that way.

```nix
virtualisation.oci-containers.proxyConfs."attic" = {
  container = "my.vps.public.ip"; # this is how my nas does it; open to the docker gateway solution if that's cleaner
  subdomain = "nix";
  port = 8080;
  protocol = "http"; # defaults to http; only needed if attic requires https
};
```

> One example of how you persist a directory for a native service on vps (an environment.persistence snippet is fine). It doesn't need to be a DynamicUser service.

See below. I use some custom options to handle cases of hosts with different persist volumes (vps is `/persist`) and non-impermanent systems (vps is impermanent)

```nix
environment.persistence.${config.systemOpts.persistVol} = lib.mkIf config.systemOpts.impermanent {
  directories = ["/var/lib/something"];
};
```

> How you declare a sops secret that holds an env file, since I'll use that for the atticd secrets.

For an env file, I would use a sops-nix template. It allows mixing of protected secrets and other data:

```nix
sops.secrets = {
  # Pull B2 credentials from secrets
  "attic/B2_keyID" = {};
  "attic/B2_key" = {};
};
# Build env and inject secrets
sops.templates."someService-env" = {
  #owner = ""; # set as needed, defaults to root
  #mode = "0444"; # set as needed, defaults to 0400
  content = ''
    # other env content
    account = ${config.sops.placeholder."attic/B2_keyID"}
    key = ${config.sops.placeholder."attic/B2_key"}
  '';
};
# Point the service to the env file location
services.someService.env = config.sops.templates."someService-env".path;
```

> Your B2 bucket's S3 endpoint, e.g. s3.us-west-004.backblazeb2.com. It's shown on the bucket page. I'd use a new, dedicated bucket for the cache rather than sharing an existing rclone one.

s3.us-west-001.backblazeb2.com

---
For the docker networking part, the gateway IP is 172.19.0.1. But it seems fragile to specify it in my config since my network definition does not declare the subnet of this network. So if I were to to have to redeploy `vps`, that subnet could be different when it's created for the first time. Below is my network creation config; is there a way to specify the subnet there?

```nix
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
```

---

2026-09-22 07:47 systemd[1]: atticd.service: Failed with result 'exit-code'.
2026-09-22 07:47 systemd[1]: atticd.service: Main process exited, code=exited, status=1/FAILURE
2026-09-22 07:47 atticd[3696220]: Error: Database error: Connection Error: error returned from database: (code: 14) unable to open database file:
error returned from database: (code: 14) unable to open database file
2026-09-22 07:47 atticd[3696220]: Running migrations...
2026-09-22 07:47 atticd[3696220]: Attic Server 0.1.0 (release)
2026-09-22 07:47 systemd[1]: Started atticd.service.

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

I'm deploying now - while that's in progress, are there any concerns about having this webui exposed to the internet? I previously had no ports open on vps and just accessed it via tailscale, but I had to open 443 in order for the runner to be able to reach it.

---

OK we can revisit that in a bit. But for now, `atticd.service` is failing to start:

```
2026-09-22 07:47 systemd[1]: atticd.service: Failed with result 'exit-code'.
2026-09-22 07:47 systemd[1]: atticd.service: Main process exited, code=exited, status=1/FAILURE
2026-09-22 07:47 atticd[3696220]: Error: Database error: Connection Error: error returned from database: (code: 14) unable to open database file:
error returned from database: (code: 14) unable to open database file
2026-09-22 07:47 atticd[3696220]: Running migrations...
2026-09-22 07:47 atticd[3696220]: Attic Server 0.1.0 (release)
2026-09-22 07:47 systemd[1]: Started atticd.service.
```

---

I'm now seeing this error:

```
Sep 22 08:27:52 vps systemd[1]: Started atticd.service.
Sep 22 08:27:52 vps (atticd)[4673]: atticd.service: Found pre-existing public StateDirectory= directory /var/lib/atticd, migrating to /var/lib/private/atticd.
Sep 22 08:27:52 vps (atticd)[4673]: atticd.service: Apparently, service previously had DynamicUser= turned off, and has now turned it on.
Sep 22 08:27:52 vps (atticd)[4673]: atticd.service: Failed to set up special execution directory in /var/lib: Device or resource busy
Sep 22 08:27:52 vps (atticd)[4673]: atticd.service: Failed at step STATE_DIRECTORY spawning /nix/store/2hh32lz0k71c74swnqxhwvd90hy9a0gf-attic-0-unstable-2026-07-06/bin/atticd: >
Sep 22 08:27:52 vps systemd[1]: atticd.service: Main process exited, code=exited, status=238/STATE_DIRECTORY
Sep 22 08:27:52 vps systemd[1]: atticd.service: Failed with result 'exit-code'.
Sep 22 08:27:52 vps systemd[1]: atticd.service: Consumed 8ms CPU time over 10.147s wall clock time, 2.9M memory peak, 2.5M read from disk.
```

I've verified that `/var/lib/atticd` exists and is owned by `atticd`. It is also properly bind mounted to `/persist` in `/etc/mtab`.

---
OK atticd is up and running with impermanence. I've also created tokens for for admin (create/delete/configure nixos-cache) and for github (push/pull only). I've verified I can manually push objects up to my cache. I have added the cache endpoint and public key to cache substituters in my nixos config. Now:
1. How do I set the github workflow to pull from and push to the cache?
2. How do I set my nixos configuration to pull from the cache?

I assume the substituter alone is not enough for pulling since it is a private cache and needs a token to authenticate.

---

To clarify, the total size of the 2 files transferred over ~3 min was 864 MB, so that should be 30 Mbps total, or about 15 Mbps per file. Several other files were transferred but they were smaller so it was harder to get a read on transfer speed for those. I tested a 1 GB transfer from `vps` to home using `scp` and got 22 MBps, or 176 Mbps; much faster. Transferring from B2 directly to home ran at 480 Mbps (this is the nominal speed of my home connection, so there is a bottleneck at vps down to 176 Mbps, but not so low as 30 Mbps). Transferring a 1 GB file from B2 to vps was around 800 Mbps. So it sounds like the chunking is causing the lower bandwidth. B2 storage is cheap, so I am fine with tuning the chunking parameters fairly aggressively to at least max out `vps`'s transfer capacity.

---

OK let's go ahead and add the `attic push` to the `update` job. `uptix` doesn't seem to change much (last commit was 10 months ago), so I expect the version built in the `build` sections from the prior week would probably still be current. But it would be best to have the push there explicitly. I'm not sure what to do for `path-info` - running `nix path-info github:luizribeiro/uptix` shows a derivation but it says `error: path '/nix/store/ml14n5hr48n02bx084hcb5azfcd573d9-uptix-0.1.0' is not valid`. Ultimately, the `update` section needs access to the `uptix` binary, and the `build` section needs access to `nixosModules.uptix`.

For the tailnet, yes let's plan on writing some basic ACLs for my tailnet. And for the runner auth, we can go with your recommendation of OIDC.

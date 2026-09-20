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

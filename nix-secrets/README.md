# Secrets

## Secrets repo

This is an example of my nix-secrets repository. I manage my secrets in a private nix-secrets repo defined in the main repo's `flake.nix`. Even though sensitive contents are encrypted, I prefer they stay [reasonably private](https://github.com/getsops/sops?tab=readme-ov-file#weak-aes-cryptography). 

## Sources of secrets

This repo contains 2 sources of secrets:

1. `flake.nix`: this is a simple flake with less-sensitive information like email addresses but that I prefer are not on the internet to be scraped. Values are imported into the `secrets` let binding in the main repo's `flake.nix`. 
2. various encrypted yaml files: these are `sops-nix` archives which are encrypted at rest. It is imported through the flake input `nix-secrets` and decrypted at build time. This is used for real secrets like passwords and ssh keys.

`sops-nix` is the preferred method for sensitive information since it does not leak world-readable secrets to `/nix/store` and is encrypted on the remote. But some modules do not support the `sops-nix` method of deploying secrets, which is usually `"cat ${config.sops.secrets."secret/name".path}"`. In particular this does not work for `accounts.email.accounts.<name>.address` home-manager option which expects an input in the format of `name@domain.tld` - [example](https://discourse.nixos.org/t/is-there-a-way-to-configure-email-accounts-without-putting-personal-info-in-cleartext-home-manager/41216/2). So some secrets are imported directly from the flake. These less-critical secrets are world-readable in `/nix/store` and are unencrypted on my private repo but I'm more concerned about keeping them off of my public repo (like email addresses).

## SOPS file structure

`.sops.yaml` contains a list of public keys and the files that are to be encrypted with those public keys. The simplest method is to have one file encrypted with all user and host keys, but this lets all users see each others' secrets as well as system secrets. That may be fine depending 

This repo has a separate yaml file for each user and each machine, as well as a `common.yaml` file with shared secrets. This keeps users and machines from seeing secrets they don't need to see. This is probably overkill for my use case but I wanted to try it as a project.

When pulling secrets in the configuration, the needed `sopsFile` can be specified. A `defaultSopsFile` can also be specified. Examples of both of these are in `configuration.nix` and `home.nix`. Most of my secrets are in the system- or user-specific files, so I set those as defaults and specify `common.yaml` where needed.

## Keys

This repo is designed for each user and each machine to have a key. Machine keys are derived from the ssh host key so no separate key needs to be maintained. User keys are standalone `age` keys that live in `$HOME/.config/sops/age`.

I also have a separate `admin` user key that lives only on my primary machine where I maintain my secrets repo. This keeps me from getting locked out from editing other machines' yaml files.

## Setting up SOPS

To set up `SOPS`, I would recommend EmergentMind's or VimJoyer's video tutorials. If you don't put it in a separate repo, you'll need to adjust how secrets are pulled into the config in `flake.nix`.

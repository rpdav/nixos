# Nixos Config

## Secrets

`nix-secrets` is a root-level directory excluded from this repo. It is managed in a private nix-secrets repo. Even though contents are encrypted, I prefer they stay [reasonably private](https://github.com/getsops/sops?tab=readme-ov-file#weak-aes-cryptography). It contains 2 sources of secrets:

1. `secrets.yaml`: this is a sops-nix archive which is encrypted at rest. It is imported through the flake input `mysecrets` and decrypted at runtime.
2. `secrets.json`: this is in clear text on disk but is encrypted by git-crypt when pushed to a remote.

`sops-nix` is preferred since it does not leak unencrypted secrets to `/nix/store`. But some modules do not support the `sops-nix` method of deploying secrets, which is usually `"cat ${secret.path}"`. In particular this does not work for `accounts.email.accounts.<name>.address` home-manager option which expects an input in the format of `name@domain.tld` - [example](https://discourse.nixos.org/t/is-there-a-way-to-configure-email-accounts-without-putting-personal-info-in-cleartext-home-manager/41216/2). So some secrets are imported directly from the json file where sops-nix does not work.
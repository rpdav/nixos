# Secrets

This is an example of my private nix-secrets repository. To use it, set up private keys for sops and edit .sops.yaml with their public keys. If you don't put it in a separate repo, you'll need to adjust how secrets are pulled into the config in flake.nix


I manage my secrets in a private nix-secrets repo defined in the main repo's `flake.nix`. Even though contents are encrypted, I prefer they stay [reasonably private](https://github.com/getsops/sops?tab=readme-ov-file#weak-aes-cryptography). It contains 2 sources of secrets:

1. `secrets.yaml`: this is a sops-nix archive which is encrypted at rest. It is imported through the flake input `nix-secrets` and decrypted at runtime.
2. `flake.nix`: this is a simple flake with less-sensitive information like email addresses. Values are imported into the `secrets` let binding in the main repo's flake.nix.

`sops-nix` is the preferred method since it does not leak world-readable secrets to `/nix/store` and is encrypted on the remote. But some modules do not support the `sops-nix` method of deploying secrets, which is usually `"cat ${config.sops.secrets.secretname.path}"`. In particular this does not work for `accounts.email.accounts.<name>.address` home-manager option which expects an input in the format of `name@domain.tld` - [example](https://discourse.nixos.org/t/is-there-a-way-to-configure-email-accounts-without-putting-personal-info-in-cleartext-home-manager/41216/2). It also does not work for endpoints in wireguard configs. So some secrets are imported directly from the flake. These less-critical secrets are world-readable in `/nix/store` and are unencrypted on my private repo but I'm more concerned about keeping them off of my public repo (like email addresses).

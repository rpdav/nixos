{inputs, ...}: {
  # All first-level attributes must be explicitly inherited here
  inherit
    (inputs.nix-secrets)
    ryan
    selfhosting
    vps
    ;
}

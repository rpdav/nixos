{ inputs, ... }:
{
  # All first-level attributes must be explicitly inherited here
  inherit (inputs.nix-secrets)
    personal-mail
    admin-mail
    calendar
    wireguard
    selfhosting
    ;
}

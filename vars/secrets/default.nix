{ inputs, ... }:
{
  inherit (inputs.nix-secrets)
    personal-mail
    admin-mail
    calendar
    wireguard
    selfhosting
    ;
}

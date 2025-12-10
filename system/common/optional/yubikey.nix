{
  outputs,
  lib,
  ...
}: {
  imports = [outputs.nixosModules.yubikey];
  # enable keys and set identifiers
  yubikey = {
    enable = true;
    identifiers = {
      yubi5c = 23559438;
      yubinano = 31767330;
    };
  };

  # passwordless sudo - see ../../optional/yubikey.nix and modules/nixos/yubikey
  security.pam.services.login.u2fAuth = lib.mkForce false; # Enabled in yubikey module by default; I prefer password login since I leave my key in at all times
}

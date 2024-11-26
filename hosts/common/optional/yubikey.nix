{lib, ...}: {
  # enable keys and set identifiers
  yubikey = {
    enable = true;
    identifiers = {
      yubi5c = 23559438;
      yubi5pink = 24410505;
      #      yubinano = 12549033;
      #      r-5 = 123456;
    };
  };

  # passwordless sudo - see ../../optional/yubikey.nix and modules/nixos/yubikey
  security.pam.services.login.u2fAuth = lib.mkForce false; # Enabled in yubikey module by default; I prefer password login since I leave my key in at all times
}

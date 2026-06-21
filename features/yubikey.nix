{self, ...}: {
  flake.nixosModules.yubikeyConfig = {lib, ...}: {
    imports = [self.nixosModules.yubikey];
    # enable keys and set identifiers
    yubikey = {
      enable = true;
      identifiers = {
        yubi5c = 23559438;
        yubinano = 31767330;
      };
    };

    security.pam.services.login.u2fAuth = lib.mkForce false; # Enabled in yubikey module by default; I prefer password login since I leave my key in at all times
  };
}

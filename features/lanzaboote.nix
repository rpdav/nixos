{inputs, ...}: {
  flake.nixosModules.lanzaboote = {config, ...}: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "${config.systemOpts.persistVol}/etc/secureboot";
    };
  };
}

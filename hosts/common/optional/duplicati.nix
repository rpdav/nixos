{
  config,
  lib,
  ...
}: let
  inherit (config) systemOpts;
in {
  # Create impermanent directory
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    directories = [
      "/var/lib/duplicati"
    ];
  };

  services.duplicati = {
    enable = true;
    user = "root";
    port = 80;
  };
}

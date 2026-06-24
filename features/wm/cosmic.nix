{...}: {
  flake.nixosModules.cosmic = {...}: {
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;
    environment.cosmic.excludePackages = [];
    services.system76-scheduler.enable = true;
  };
  flake.homeModules.cosmic = {
    config,
    osConfig,
    lib,
    pkgs,
    ...
  }: let
    inherit (osConfig) systemOpts;
  in {
    home.persistence."${systemOpts.persistVol}" = lib.mkIf config.userOpts.impermanent {
      directories = [
        ".config/cosmic"
      ];
    };
    home.packages = with pkgs; [
      quick-webapps
    ];
  };
}

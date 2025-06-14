{
  systemOpts,
  userOpts,
  lib,
  pkgs,
  ...
}: {
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".config/cosmic"
    ];
  };
  home.packages = with pkgs; [
    quick-webapps
  ];
}

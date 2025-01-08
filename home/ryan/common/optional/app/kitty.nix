{
  pkgs,
  lib,
  systemOpts,
  userOpts,
  ...
}: {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".terminfo"
    ];
  };
  home.packages = with pkgs; [
    kitty
  ];
  programs.kitty.enable = true;
}

{...}: {
  flake.homeModules.cinnamon = {pkgs, ...}: {
    home.packages = with pkgs; [
    ];
  };
}

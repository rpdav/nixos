{...}: {
  flake.nixosModules.cinnamon = {...}: {
    services.displayManager.defaultSession = "cinnamon";

    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.cinnamon.enable = true;
    };
  };
  flake.homeModules.cinnamon = {pkgs, ...}: {
    home.packages = with pkgs; [
    ];
  };
}

{...}: {
  flake.homeModules.swaylock = {pkgs, ...}: {
    # it's letting me incorrectly unlock via yubikey
    programs.swaylock = {
      package = pkgs.swaylock-effects;
      enable = true;
      settings = {
        #color = "808080";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        #line-color = "ffffff";
        show-failed-attempts = true;
      };
    };
  };
}

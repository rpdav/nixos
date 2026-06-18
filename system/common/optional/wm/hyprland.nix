{...}: {
  flake.nixosModules.hyprland = {
    inputs,
    config,
    pkgs,
    ...
  }: {
    services.displayManager = {
      autoLogin.user = "ryan";
      gdm = {
        enable = true;
      };
      defaultSession = "hyprland";
    };

    boot.loader.timeout = 0;

    # needed for wlogout icons
    programs.gdk-pixbuf.modulePackages = [pkgs.librsvg];

    # Keyring
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      font-awesome
    ];

    #needed for waybar
    users.users.ryan = {
      extraGroups = ["input"];
    };

    # Misc tweaks
    services.logind.settings.Login.HandlePowerKey = "ignore"; # Override power button behavior to use wlogout

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
    };
  };
}

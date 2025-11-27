{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [./plymouth];

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = config.systemOpts.primaryUser;
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/Hyprland";
        user = "greeter";
      };
    };
  };

  boot.loader.timeout = 0;

  # needed for wlogout icons
  programs.gdk-pixbuf.modulePackages = [pkgs.librsvg];

  security.pam.services.greetd = {
    # Disable fprint and yubikey login
    fprintAuth = false;
    u2fAuth = false;
    enableGnomeKeyring = true;
  };

  # Keyring
  services.gnome.gnome-keyring.enable = true;

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

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
}

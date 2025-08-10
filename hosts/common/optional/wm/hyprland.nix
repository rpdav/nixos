{
  inputs,
  pkgs,
  ...
}: {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/Hyprland";
        user = "greeter";
      };
      default_session = initial_session;
    };
  };

  security.pam.services.greetd = {
    # Disable fprint and yubikey login
    fprintAuth = false;
    u2fAuth = false;
    enableGnomeKeyring = true;
  };
  #  services.greetd = {
  #    enable = true;
  #    settings = {
  #      default_session = {
  #        command = "${pkgs.hyprland}/bin/hyprctl dispatch exec ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
  #        user = "ryan";
  #      };
  #      bash = {
  #        command = "${pkgs.bash}/bin/bash";
  #      };
  #      hyprland = {
  #        command = "${pkgs.hyprland}/bin/Hyprland";
  #      };
  #    };
  #  };

  #  environment.etc."greetd/environments".text = ''
  #    bash
  #    hyprland
  #  '';

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

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
}

{
  pkgs,
  inputs,
  config,
  configLib,
  self,
  ...
}: let
  inherit (config) systemOpts;
in {
  ## This file contains NixOS configuration common to all hosts

  imports = [
    (configLib.relativeToRoot "vars")
    ./persistence
    ./packages.nix
    ./regressions.nix
    ./sops.nix
    ./sshd.nix #needed for sops keys
    ./stylix.nix
    ./tailscale.nix
    ./vim.nix

    inputs.disko.nixosModules.disko
  ];

  # Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
      keep-outputs = true
      keep-derivations = true
      warn-dirty = false
    '';
  };

  # Cache substituters
  # Putting all config-wide substituters here so that hosts can use them for building
  # even if they aren't needed for all hosts
  nix.settings = {
    substituters = [
      "https://nvf.cachix.org"
      "https://hyprland.cachix.org"
      "https://watersucks.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  environment.variables = {
    EDITOR = "nvim";
  };

  # Put link to current flake in etc to help troubleshooting
  environment.etc."current-system-flake".source = self;

  # Base fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
    ];
    fontconfig.enable = true;
  };

  # Allow local users to inhibit sleep (used for some systemd user units)
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.login1.inhibit-block-shutdown" &&
          subject.isInGroup("users"))
              return polkit.Result.YES;
      });
    '';
  };

  # Automate garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than ${systemOpts.gcRetention}";
  };

  # CLI config
  programs.bash.completion.enable = true;
  environment.enableAllTerminfo = true;

  # Time
  time.timeZone = "America/Indiana/Indianapolis";
}

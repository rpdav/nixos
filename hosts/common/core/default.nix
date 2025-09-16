{
  pkgs,
  inputs,
  config,
  ...
}: let
  inherit (config) systemOpts;
in {
  ## This file contains NixOS configuration common to all hosts

  imports = [
    ./packages.nix
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
    dates = systemOpts.gcInterval;
    options = "--delete-older-than ${systemOpts.gcRetention}";
  };

  # CLI config
  programs.bash.completion.enable = true;
  environment.enableAllTerminfo = true;

  # Time
  time.timeZone = "America/Indiana/Indianapolis";
}

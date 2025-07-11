{
  systemOpts,
  userOpts,
  inputs,
  config,
  ...
}: {
  ## This file contains NixOS configuration common to all hosts

  imports = [
    ./tailscale.nix
    ./packages.nix
    ./sops.nix
    ./sshd.nix #needed for sops keys
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

  # Automate garbage collection
  nix.gc = {
    automatic = true;
    dates = systemOpts.gcInterval;
    options = "--delete-older-than ${systemOpts.gcRetention}";
  };

  # CLI config
  programs.bash.completion.enable = true;
  environment.enableAllTerminfo = true;

  # Options search and nixos CLI tooling
  services.nixos-cli = {
    enable = true;
    config = {
      config_location = "/home/${userOpts.username}/nixos";
      apply.use_git_commit_msg = true;
      apply.imply_impure_with_tag = true;
      apply.use_nom = true;
    };
  };
  nix.settings = {
    substituters = ["https://watersucks.cachix.org"];
    trusted-public-keys = [
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
    ];
  };

  # Time
  time.timeZone = config.systemOpts.timezone;
}

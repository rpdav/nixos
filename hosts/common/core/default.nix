{
  systemOpts,
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

  # Time
  time.timeZone = config.systemOpts.timezone;
}

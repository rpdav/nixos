{
  systemOpts,
  inputs,
  ...
}: {
  ## This file contains NixOS configuration common to all hosts

  imports = [
    #TODO change this back once done with testbox
    #./tailscale.nix
    #./packages.nix
    #./sops.nix
    #./sshd.nix #needed for sops keys

    inputs.nixos-cli.nixosModules.nixos-cli
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
  services.nixos-cli.enable = true;
  programs.bash.completion.enable = true;

  # Time
  time.timeZone = systemOpts.timezone;
}
